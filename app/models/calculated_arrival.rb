class CalculatedArrival
  attr_reader :attributes

  def self.all
    vehicles = VehiclePosition.by_trip_with_deviation(:include_docs => true).docs
    self.calculate_for_vehicles(vehicles)
  end

  def self.find_for_stop_and_now(stop_id)
    stop_trip_ids = StopTime.trip_ids_for_stop(stop_id)
    vehicles = VehiclePosition.by_trip_with_deviation(:keys => stop_trip_ids.uniq, :include_docs => true).docs
    result = self.calculate_for_vehicles(vehicles)
    result.select do |ca|
      (ca["stop_id"] == stop_id)
    end
  end

  def self.calculate_for_vehicles(vehicles)
    trip_ids = vehicles.map(&:trip_id)
    found_trips = Trip.trip_collection_with_stops(trip_ids)
    route_names = Route.route_collection(found_trips.map(&:route_id)).inject({}) do |h, r|
      h[r.route_id] = r.route_long_name
      h
    end
    vehicle_trips = found_trips.inject({}) { |memo, val| memo[val.trip_id] = val; memo }
    vehicle_stuff = (vehicles.map do |v|
      v.calculate_adjusted_stops(vehicle_trips[v.trip_id])
    end).flatten
    result = vehicle_stuff.map do |ast|
      CalculatedArrival.new(vehicle_trips[ast["trip_id"]], route_names, ast)
    end
  end

  def initialize(trip, route_names, attr = {})
    @attributes = attr.dup
    @attributes[:stop_time_id] = attr["_id"]
    @attributes[:vehicle_id] = attr["vehicle_id"]
    @attributes[:trip_id] = trip.trip_id
    @attributes[:route_name] = route_names[trip.route_id]
    @attributes[:route_id] = trip.route_id
    @attributes[:destination_stop_name] = trip.last_stop_name
    @attributes[:trip_headsign] = trip.trip_headsign
    @attributes[:calculated_time] = attr["scheduled_time"]
    @attributes[:calculated_display_time] = attr["scheduled_time"].strftime("%l:%M%p") # for some reason super expensive
    @attributes[:message] = "#{@attributes[:calculated_display_time]} #{@attributes[:route_name]} to #{trip.last_stop_name}"
  end

  def [](key)
    @attributes[key]
  end

  def to_json
    attributes.to_json
  end

  def to_xml(opts = {})
    attributes.to_xml(opts)
  end
end
