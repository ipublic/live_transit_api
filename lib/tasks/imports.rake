require 'csv'

def run_sql_with_progress(start_msg, stop_msg, *args)
  puts start_msg
  args.each do |sql_str|
    ActiveRecord::Base.connection.execute(sql_str)
  end
  puts stop_msg
end

def read_csv_headers(import_file)
  headers = []
  CSV.open(import_file, {:headers => true}) do |csv|
    iter = csv.to_enum(:each)
    headers = iter.next.headers
  end
  headers
end

def import_batch_with_transformation(object_list_type, batch_size, import_file, model_cls, model_headers)
  recs = []
  total = 0 
  puts "Import #{object_list_type}...."
  CSV.foreach(import_file, {:headers => true}) do |row|
    total += 1
    recs << (yield row.fields)
    if total % batch_size == 0
      model_cls.import model_headers, recs, :validate => false
      recs = []
      puts "#{total} #{object_list_type} in"
    end
  end
  model_cls.import model_headers, recs, :validate => false
  puts "#{total} #{object_list_type} in"
end

def import_batch_with_progress(object_list_type, batch_size, import_file, model_cls)
  header_cols = read_csv_headers(import_file)
  recs = []
  total = 0 
  puts "Import #{object_list_type}...."
  CSV.foreach(import_file, {:headers => true}) do |row|
    total += 1
    recs << row.fields
    if total % batch_size == 0
      model_cls.import header_cols, recs, :validate => false
      recs = []
      puts "#{total} #{object_list_type} in"
    end
  end
  model_cls.import header_cols, recs, :validate => false
  puts "#{total} #{object_list_type} in"
end

desc "Create DB"
task :create_import_db => :environment do 
  db_name = "lta_#{Time.now.strftime("%Y%m%d%H%M%S")}"
  db_config = ActiveRecord::Base.configurations["production"]
  new_config = db_config.clone
  new_config["database"] = db_name
  create_database(new_config)
  ActiveRecord::Base.establish_connection(new_config)
  ActiveRecord::Migrator.migrate("db/migrate")
end

namespace :gtfs do

desc "Import Data"
task :import_data => :environment do
  started_at_time = Time.now
  puts "Started at #{started_at_time}"
  import_batch_with_progress("shape points", 5000, "shapes.txt", ShapePoint)
  puts "Import schedules"
  agencies = []
  puts "Import agencies...."
  CSV.foreach("agency.txt", {:headers => true}) do |row|
    agencies << Agency.new(row.to_hash)
  end
  Agency.import agencies, :validate => false
  import_batch_with_progress("stops", 1000, "stops.txt", ::Stop)
  import_batch_with_progress("routes", 1000, "routes.txt", Route)
  puts "Import schedules"
  sp = Loaders::ServiceProcessor.new(
            "calendar.txt",
            "calendar_dates.txt"
  )
  service_days = []
  total = 0
  sp.enumerated_services.each_pair do |k, v|
    v.each do |d|
      total += 1
      service_days << [k, d]
    end
  end
  TripDay.import ["service_id", "day"], service_days, :validate => "false"
  puts "#{total} scheduled days in"
  columns = read_csv_headers("trips.txt")
  import_batch_with_progress("trips", 2500, "trips.txt", Trip)
  stop_times = []
  columns = []
  arr_time_idx = 0
  d_time_idx = 0
  total = 0 
  puts "Import stop_times..."
  st_cols = read_csv_headers("stop_times.txt")
  arr_time_idx = st_cols.index("arrival_time")
  d_time_idx = st_cols.index("departure_time")
  import_batch_with_transformation("stop times", 5000, "stop_times.txt", StopTime, st_cols) do |row|
    field_vals = row
    at_components = field_vals[arr_time_idx].split(":").map(&:to_i)
    dt_components = field_vals[d_time_idx].split(":").map(&:to_i)
    field_vals[arr_time_idx] = ((at_components[0] * 3600) + (at_components[1] * 60) + at_components[2])
    field_vals[d_time_idx] = ((dt_components[0] * 3600) + (dt_components[1] * 60) + dt_components[2])
    field_vals
  end
  run_sql_with_progress(
    "Updating trips with last_stop_sequence",
    "Done updating trips",
    <<-SQLCODE,
      update trips
      set last_stop_sequence = blah.last_stop_sequence
      from
          (select max(stop_sequence) as last_stop_sequence, trip_id from stop_times group by trip_id) as blah
            where blah.trip_id = trips.trip_id
    SQLCODE
    <<-SQLCODE)
    alter table trips alter column last_stop_sequence set not null
    SQLCODE
  run_sql_with_progress(
    "Building stop_time_services",
    "Done stop_time_services",
    <<-SQLCODE)
      insert into stop_time_services
      select st.id, st.stop_id, t.service_id, st.arrival_time, st.departure_time from stop_times st
      join trips t on t.trip_id = st.trip_id
    SQLCODE
  puts "Building stop_time_events"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  insert into stop_time_events
  select sc.stop_time_id, sc.stop_id, (td.day + sc.arrival_time), (td.day + sc.departure_time) from
  stop_time_services sc
  inner join trip_days td on sc.service_id = td.service_id
  SQLCODE
  puts "Done stop_time_events"
  puts "Building stop_time_events primary key"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  alter table stop_time_events add column id serial
  SQLCODE
  puts "Added stop_time_events id"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  alter table stop_time_events add primary key (id)
  SQLCODE
  puts "Done stop_time_events primary key"
  puts "Building stop_time_events index on stop_time_id"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  create index index_stop_time_events_on_stop_time_id
  on stop_time_events (stop_time_id)
  SQLCODE
  puts "Done stop_time_events index on stop_time_id"
  puts "Building stop_time_events index on stop_id"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  create index index_stop_time_events_on_stop_id
  on stop_time_events (stop_id)
  SQLCODE
  puts "Done stop_time_events index on stop_id"
  puts "Building stop_time_events index on arrival_time"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  create index index_stop_time_events_on_arrival_time
  on stop_time_events (arrival_time)
  SQLCODE
  puts "Done stop_time_events index on arrival_time"
  puts "Building stop_time_events index on departure_time"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  create index index_stop_time_events_on_departure_time
  on stop_time_events (departure_time)
  SQLCODE
  puts "Done stop_time_events index on departure_time"
  ended_at_time = Time.now
  puts "Started at #{started_at_time}"
  puts "Ended at #{ended_at_time}"
end

end
