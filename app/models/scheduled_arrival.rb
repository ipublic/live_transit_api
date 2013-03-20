class ScheduledArrival
  attr_reader :attributes

  def self.find_for_stop_and_now(st_id, limit)
    time = Time.now.to_i
    stes = StopTimeEvent.for_stop_and_arrival_time(st_id, time).first(limit)
    stes.map { |st| ScheduledArrival.new(st) }
  end

  def initialize(st)
    @attributes = {}
    @attributes[:stop_time_id] = st.stop_time_id
    @attributes[:stop_id] = st.stop_id
    @attributes[:route_id] = st.route.route_id
    @attributes[:route_short_name] = st.route.route_short_name
    @attributes[:route_name] = st.route.route_long_name
    @attributes[:destination_stop_name] = st.trip.last_stop_name
    @attributes[:arrival_time] = st.arrival_time
    @attributes[:departure_time] = st.departure_time
    @attributes[:trip_id] = st.stop_time.trip_id
    @attributes[:trip_headsign] = st.trip.trip_headsign
    @attributes[:scheduled_time] = Time.at(st.arrival_time)
    @attributes[:scheduled_display_time] = display_time(st.arrival_time)
    @attributes[:message] = "#{@attributes[:scheduled_display_time]} #{@attributes[:trip_headsign]} to #{st.trip.last_stop_name}"
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

  def comparison_time
    @attributes[:arrival_time]
  end

  def arrival_time
    @attributes[:scheduled_display_time]
  end

  def headsign
    @attributes[:trip_headsign]
  end

  def destination
    @attributes[:destination_stop_name]
  end

  def running_status
    "on_time" 
  end

  def on_time?
    true
  end

  def not_calculated?
    true
  end

  protected

  def display_time(time_str)
    t = Time.at(time_str)
    t.strftime("%l:%M%p")
  end
end
