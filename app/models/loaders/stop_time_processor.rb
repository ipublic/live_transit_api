class Loaders::StopTimeProcessor
  def self.load(stop_time_data, trip_schedules, trip_routes, stop_codes)
    @recs_hash = Hash.new([])
    StopTime.database.bulk_save_cache_limit = 10000
    CSV.foreach(stop_time_data, {:headers => true}) do |row|
      stop_time_hash = {
        :trip_id => row[0],
        :route_id => trip_routes[row[0]],
        :arrival_time => row[1].strip.rjust(8, "0"),
        :departure_time => row[2].strip.rjust(8, "0"),
        :stop_id => row[3].strip,
        :stop_code => stop_codes[row[3]][:stop_code],
        :stop_sequence => row[4].to_i,
        :stop_headsign => row[5],
        :schedules => trip_schedules[row[0]],
        :stop_name => stop_codes[row[3]][:stop_name],
        :stop_geometry => {
          :type => "Point",
          :coordinates => stop_codes[row[3]][:coordinates]
        },
        :type => "StopTime"
      }
      if trip_schedules.has_key?(stop_time_hash[:trip_id])
      # fix this to use/abuse indexing
      @recs_hash[stop_time_hash[:trip_id]] = @recs_hash[stop_time_hash[:trip_id]] + [
        {
          :stop_sequence => stop_time_hash[:stop_sequence],
          :departure_time => stop_time_hash[:departure_time],
          :arrival_time => stop_time_hash[:arrival_time],
          :stop_name => stop_time_hash[:stop_name]
        }
      ]
      StopTime.database.save_doc(stop_time_hash, true, true)
      end
    end
    StopTime.database.bulk_save
    StopTime.database.bulk_save_cache_limit = 500
    @recs_hash.inject({}) do |h, (k,v)|
      sorted_recs = v.sort_by { |v| v[:stop_sequence] }
      first = sorted_recs.first
      last = sorted_recs.last
      h[k] = [
        first[:arrival_time],
        last[:departure_time],
        first[:stop_name],
        last[:stop_name]
      ]
      h
    end
  end
end
