class Gtfs::RealtimeFeed
  attr_reader :trip_updates
  attr_reader :vehicle_positions

  def self.fetch
    l_time = Time.now
    time_threshold = l_time - 30.minutes
     vehicles = VehiclePosition.with_deviation(:include_docs => true).docs.reject do |veh|
       veh.last_position_time < time_threshold
     end
    [l_time, self.new(Gtfs::TripUpdate.all(vehicles), vehicles)]
  end

  def initialize(t_updates, v_positions)
    @trip_updates = t_updates
    @vehicle_positions = v_positions
  end

end
