require 'csv'

desc "Create DB"
task :create_import_db => :environment do 
  db_name = "lta_#{Time.now.strftime("%Y%m%d%H%M%S")}"
  db_config = ActiveRecord::Base.configurations["production"]
  new_config = db_config.clone
  new_config["database"] = db_name
  create_database(new_config)
  ActiveRecord::Base.establish_connection(new_config)
  ActiveRecord::Migrator.migrate("db/migrate", )
end

desc "Import Data"
task :import_data => :environment do
  started_at_time = Time.now
  puts "Started at #{started_at_time}"
  spoints = []
  total = 0 
  puts "Import shape points..."
  CSV.foreach("shapes.txt", {:headers => true}) do |row|
    total += 1
    spoints << ShapePoint.new(row.to_hash)
    if total % 5000 == 0
      ShapePoint.import spoints, :validate => false
      spoints = []
      puts "#{total} shape points in"
    end
  end
  ShapePoint.import spoints, :validate => false
  puts "#{total} shape points in"
  puts "Import schedules"
  agencies = []
  puts "Import agencies...."
  CSV.foreach("agency.txt", {:headers => true}) do |row|
    agencies << Agency.new(row.to_hash)
  end
  Agency.import agencies, :validate => false
  stops = []
  total = 0 
  puts "Import stops..."
  CSV.foreach("stops.txt", {:headers => true}) do |row|
    total += 1
    stops << Stop.new(row.to_hash)
    if total % 1000 == 0
      Stop.import stops, :validate => false
      stops = []
      puts "#{total} stops in"
    end
  end
  Stop.import stops, :validate => false
  puts "#{total} stops in"
  routes = []
  total = 0 
  puts "Import routes..."
  CSV.foreach("routes.txt", {:headers => true}) do |row|
    total += 1
    routes << Route.new(row.to_hash)
    if total % 1000 == 0
      Route.import routes, :validate => false
      routes = []
      puts "#{total} routes in"
    end
  end
  Route.import routes, :validate => false
  puts "#{total} routes in"
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
  trips = []
  columns = []
  total = 0 
  puts "Import trips..."
  CSV.foreach("trips.txt", {:headers => true}) do |row|
    total += 1
    trips << row.fields
    if total % 2500 == 0
      columns = row.headers
      Trip.import columns, trips, :validate => false
      trips = []
      puts "#{total} trips in"
    end
  end
  Trip.import columns, trips, :validate => false
  puts "#{total} trips in"
  stop_times = []
  columns = []
  arr_time_idx = 0
  d_time_idx = 0
  total = 0 
  puts "Import stop_times..."
  CSV.foreach("stop_times.txt", {:headers => true}) do |row|
    columns = row.headers
    arr_time_idx = columns.index("arrival_time")
    d_time_idx = columns.index("departure_time")
    break
  end
  CSV.foreach("stop_times.txt", {:headers => true}) do |row|
    total += 1
    field_vals = row.fields
    at_components = field_vals[arr_time_idx].split(":").map(&:to_i)
    dt_components = field_vals[d_time_idx].split(":").map(&:to_i)
    field_vals[arr_time_idx] = ((at_components[0] * 3600) + (at_components[1] * 60) + at_components[2])
    field_vals[d_time_idx] = ((dt_components[0] * 3600) + (dt_components[1] * 60) + dt_components[2])
    stop_times << field_vals
    if total % 5000 == 0
      StopTime.import columns, stop_times, :validate => false
      stop_times = []
      puts "#{total} stop times in"
    end
  end
  StopTime.import columns, stop_times, :validate => false
  puts "#{total} stop times in"
  puts "Updating trips with last_stop_sequence"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  update trips
    set last_stop_sequence = blah.last_stop_sequence
      from
          (select max(stop_sequence) as last_stop_sequence, trip_id from stop_times group by trip_id) as blah
            where blah.trip_id = trips.trip_id
  SQLCODE
  ActiveRecord::Base.connection.execute <<-SQLCODE
  alter table trips alter column last_stop_sequence set not null
  SQLCODE
  puts "Done updating trips"
  puts "Building stop_time_services"
  ActiveRecord::Base.connection.execute <<-SQLCODE
insert into stop_time_services
select st.id, st.stop_id, t.service_id, st.arrival_time, st.departure_time from stop_times st
join trips t on t.trip_id = st.trip_id
  SQLCODE
  puts "Done stop_time_services"
  ActiveRecord::Base.connection.execute <<-SQLCODE
  alter table stop_time_events add column id serial
  SQLCODE
  puts "Added stop_time_events id"
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
