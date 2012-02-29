class ScheduledArrival
  attr_reader :attributes

  def self.find_for_stop_and_now(st_id)
    date_str = Time.now.strftime("%Y-%m-%d")
    time_str = Time.now.strftime("%H:%M:%s")
    date_of_bbox = StopTime.date_of_day_bbox(st_id, date_str)
    date_before_bbox = StopTime.date_before_day_bbox(st_id, date_str)
    date_after_bbox = StopTime.date_after_day_bbox(st_id, date_str)
    todays = StopTime.find_for_bbox(date_of_bbox)
    yesterdays = StopTime.find_for_bbox(date_before_bbox)
    tomorrows = StopTime.find_for_bbox(date_after_bbox)
    trip_ids = (todays.map(&:trip_id) + tomorrows.map(&:trip_id) + yesterdays.map(&:trip_id)).uniq.sort
    trip_models =  Trip.trip_collection(trip_ids)
    trips = trip_models.inject({}) do |h, t|
        h[t.trip_id] = t
        h
    end
    found_routes = Route.route_collection(trips.values.map(&:route_id))
    route_names = found_routes.inject({}) do |h, r|
      h[r.route_id] = r
      h
    end
    ((
      todays.map { |st| ScheduledArrival.new(st, trips[st.trip_id], route_names) } +
        yesterdays.map { |st| ScheduledArrival.new(st, trips[st.trip_id], route_names, -24) } +
        tomorrows.map { |st| ScheduledArrival.new(st, trips[st.trip_id], route_names, 24) }
    ).reject { |sa| sa.attributes[:departure_time] < time_str }.sort_by { |sa| sa.attributes[:arrival_time] })
  end

  def initialize(st, trip, route_names, offset=0)
    @attributes = {}
    @attributes[:stop_time_id] = st['_id']
    @attributes[:stop_id] = st.stop_id
    @attributes[:route_id] = trip.route_id
    @attributes[:route_short_name] = route_names[trip.route_id].route_short_name
    @attributes[:route_name] = route_names[trip.route_id].route_long_name
    @attributes[:destination_stop_name] = trip.last_stop_name
    @attributes[:arrival_time] = offset_time(st.arrival_time, offset)
    @attributes[:departure_time] = offset_time(st.departure_time, offset)
    @attributes[:trip_id] = st.trip_id
    @attributes[:trip_headsign] = trip.trip_headsign
    @attributes[:scheduled_display_time] = display_time(st.arrival_time)
    @attributes[:message] = "#{@attributes[:scheduled_display_time]} #{@attributes[:trip_headsign]} to #{trip.last_stop_name}"
  end

  def [](key)
    attributes[key]
  end

  def to_json
    attributes.to_json
  end

  def to_xml(opts = {})
    attributes.to_xml(opts)
  end

  protected

  def display_time(time_str)
    time_parts = time_str.split(":")
    first_part = time_parts.first.to_i.modulo(24)
    h_value = if (first_part == 0)
                h_value = "12"
              else
                (first_part > 12) ? (first_part - 12).to_s : first_part.to_s
              end
    t_suffix = (first_part > 11) ? "PM" : "AM"
    [h_value, ":", time_parts[1], t_suffix].join
  end

  def offset_time(time_str, offset)
    time_parts = time_str.split(":")
    first_part = time_parts.first.to_i + offset
    ([first_part.to_s.rjust(2, "0")] + time_parts[1..-1]).join(":")
  end

end
