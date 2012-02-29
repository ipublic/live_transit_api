class Gtfs::TripUpdate
  attr_reader :trip_id
  attr_reader :stop_time_updates
  attr_reader :timestamp

  def self.all
     lookup_time = Time.now
     time_threshold = lookup_time - 1.hour
     vehicles = VehiclePosition.with_deviation.docs.reject do |veh|
       veh.last_position_time < time_threshold
     end
     stus = vehicles.map do |v|
       Gtfs::StopTimeUpdate.new(v.trip_id, v.previous_sequence, v.predicted_deviation)
     end
     data = stus.group_by(&:trip_id).map do |(k,v)|
       Gtfs::TripUpdate.new(k, v)
     end
     [lookup_time.to_i, data]
  end

  def initialize(t_id, st_updates)
    @trip_id = t_id
    @stop_time_updates = st_updates
  end

  def gtfs_id
   "trip_#{trip_id}_stop_time_update"
  end
  
end
