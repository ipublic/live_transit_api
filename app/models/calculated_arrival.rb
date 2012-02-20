class CalculatedArrival
  attr_reader :attributes

  def self.find_for_stop_and_now(stop_id)
    stop_trip_ids = Rails.cache.fetch("trips_for_stop_#{stop_id}") {
      Rails.logger.info "Fetching trips_for_stop_#{stop_id} from couchdb!"
      StopTime.trips_for_stop(:key => stop_id, :view => :for_stop_id).all }
    vehicles = VehiclePosition.by_trip_id(:keys => stop_trip_ids.uniq, :include_docs => true).docs
    trip_ids = vehicles.map(&:trip_id).uniq.sort
    trip_ids_keys = "found_calculated_trips_" + Digest::SHA512.hexdigest(trip_ids.to_s)
    found_trips = Rails.cache.fetch(trip_ids_keys) {
      Rails.logger.info "Fetching found_calculated_trips_#{trip_ids} from couchdb!"
      Trip.by_trip_id(:keys => trip_ids, :include_docs => true).docs
    }.dup
    trip_stops_keys = "stops_for_trip_list_" + Digest::SHA512.hexdigest(trip_ids.to_s)
    found_stops = Rails.cache.fetch(trip_stops_keys) {
      Rails.logger.info "Fetching stops_for_trip_list_#{trip_ids} from couchdb!"
      StopTime.multiple_trip_stops(:keys => trip_ids, :view => :for_trip_id).all
    }.dup
    found_trips.each do |ft|
      ft.stops = found_stops[ft.trip_id]
    end
    route_names = Route.by_route_id(:keys => found_trips.map(&:route_id)).inject({}) do |h, r|
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
