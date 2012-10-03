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
  trips = []
  total = 0 
  puts "Import trips..."
  CSV.foreach("trips.txt", {:headers => true}) do |row|
    total += 1
    trips << Trip.new(row.to_hash)
    if total % 2500 == 0
      Trip.import trips, :validate => false
      trips = []
      puts "#{total} trips in"
    end
  end
  Trip.import trips, :validate => false
  puts "#{total} trips in"
  stop_times = []
  total = 0 
  puts "Import stop_times..."
  columns = []
  CSV.foreach("stop_times.txt", {:headers => true}) do |row|
    columns = row.headers
    total += 1
    stop_times << row.fields
    if total % 25000 == 0
      StopTime.import columns, stop_times, :validate => false
      stop_times = []
      puts "#{total} stop times in"
    end
  end
  StopTime.import columns, stop_times, :validate => false
  puts "#{total} stop times in"
end
