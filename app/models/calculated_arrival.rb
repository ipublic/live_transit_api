class CalculatedArrival
  attr_reader :attributes

  def self.find_for_stop_and_now(stop_id)
    stop_trip_ids = Rails.cache.fetch("trips_for_stop_#{stop_id}") { StopTime.trips_for_stop(:key => stop_id, :view => :for_stop_id) }
    vehicles = VehiclePosition.by_trip_id(:keys => stop_trip_ids, :include_docs => true).docs
    trip_ids = vehicles.map(&:trip_id)
    found_trips = Trip.by_trip_id(:keys => trip_ids, :include_docs => true).docs
    found_stops = StopTime.multiple_trip_stops(:keys => trip_ids, :view => :for_trip_id).all
    found_trips.each do |ft|
      ft.stops = found_stops[ft.trip_id]
    end
    route_names = Route.by_route_id(:keys => found_trips.map(&:route_id)).inject({}) do |h, r|
      h[r.route_id] = r.route_long_name
      h
    end # 2 seconds so far
    vehicle_trips = found_trips.inject({}) { |memo, val| memo[val.trip_id] = val; memo } # 0.1 second
    vehicle_stuff = vehicles.map do |v|
      v.calculate_adjusted_stops(vehicle_trips[v.trip_id])
    end.flatten
    # 2.3 seconds to here
    result = vehicle_stuff.map do |ast|
      CalculatedArrival.new(vehicle_trips[ast["trip_id"]], route_names, ast)
    end # 1.4 seconds, down from 4
    result.select do |ca|
      ca["stop_id"] == stop_id
    end
  end

  def initialize(trip, route_names, attr = {})
    @attributes = attr.dup
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
