require 'csv'

desc "Import Data"
task :import_data => :environment do
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
end
