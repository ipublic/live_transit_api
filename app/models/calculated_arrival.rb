class CalculatedArrival
  attr_reader :attributes

  def self.all
    vehicles = VehiclePosition.all
    trip_ids = vehicles.map(&:trip_id)
    found_trips = Trip.by_trip_id(:keys => trip_ids).all
    found_stops = StopTime.multiple_trip_stops(:keys => trip_ids, :view => :for_trip_id).all
    found_trips.each do |ft|
      ft.stops = found_stops[ft.trip_id]
    end
    route_names = Route.by_route_id(:keys => found_trips.map(&:route_id)).inject({}) do |h, r|
      h[r.route_id] = r.route_long_name
      h
    end
    vehicle_trips = found_trips.inject({}) { |memo, val| memo[val.trip_id] = val; memo }
    vehicles.map do |v|
      v.calculate_adjusted_stops(vehicle_trips[v.trip_id])
    end.flatten.map do |ast|
      CalculatedArrival.new(vehicle_trips[ast["trip_id"]], route_names, ast)
    end
  end

  def self.find_for_stop_and_now(stop_id)
    self.all.select do |ca|
      ca["stop_id"] == stop_id
    end
  end

  def initialize(trip, route_names, attr = {})
    @attributes = attr.dup
    @attributes[:route_name] = route_names[trip.route_id]
    @attributes[:route_id] = trip.route_id
    @attributes[:destination_stop_name] = trip.last_stop_name
    @attributes[:trip_headsign] = trip.trip_headsign
    @attributes[:scheduled_time] = attr["scheduled_time"]
    @attributes[:display_time] = attr["scheduled_time"].strftime("%l:%M%p")
    @attributes[:message] = "#{@attributes[:display_time]} #{@attributes[:route_name]} to #{trip.last_stop_name}"
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
