require 'csv'
require 'enumerator'

class Loaders::TripProcessor
  attr_reader :trip_records
  attr_reader :trip_schedules
  attr_reader :trip_routes

  def initialize(trip_data, keyed_services)
    @trip_records = []
    @trip_schedules = {}
    @trip_routes = {}
    CSV.foreach(trip_data, {:headers => true, :header_converters => :symbol}) do |row|
      trip_hash = row.to_hash
      if !keyed_services[trip_hash[:service_id]].empty? 
        @trip_schedules[trip_hash[:trip_id]] = keyed_services[trip_hash[:service_id]]
        @trip_routes[trip_hash[:trip_id]] = trip_hash[:route_id]
        @trip_records.push(
            trip_hash.merge({:schedules => keyed_services[trip_hash[:service_id]], :type => "Trip"})
        )
      end
    end
  end

  def process_additional_records_and_persist(stop_time_processor)
    @trip_records.each { |tr|
      tr[:start_time] = stop_time_processor[tr[:trip_id]].first
      tr[:end_time] = stop_time_processor[tr[:trip_id]][1]
      tr[:first_stop_name] = stop_time_processor[tr[:trip_id]][2]
      tr[:last_stop_name] = stop_time_processor[tr[:trip_id]].last
      CouchRest::Model::Base.database.bulk_save_doc(tr)
    }
    CouchRest::Model::Base.database.bulk_save
  end
end
