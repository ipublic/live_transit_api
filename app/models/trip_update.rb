class TripUpdate

  def self.all
    vehicles = VehiclePosition.all
    trip_ids = vehicles.map(&:trip_id).uniq
  end

end
