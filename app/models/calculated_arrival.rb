class CalculatedArrival
  attr_reader :attributes

  def self.find_for_stop_and_now(stop_id)
    calc_time = Time.now
    reporting_cutoff = calc_time - 30.minutes
    vp = VehiclePosition.all(:include_docs => true).docs.reject do |v|
      (v.predicted_deviation == 63) || (v.latest_report_time < reporting_cutoff)
    end
    vp_trips = vp.map { |vp| vp.trip_id }.uniq
    vp_trip_models = Trip.by_trip_ids(vp_trips)
    vp_block_map = vp_trip_models.inject({}) do |memo, t|
      memo[t.trip_id] = t.block_id
      memo
    end
    vp_blocks = vp.inject({}) do |memo, vp|
      memo[vp_block_map[vp.trip_id]] = vp
      memo
    end
    max_dev = (vp.map { |v| v.predicted_deviation.abs }.max) * 60
    start_time = calc_time.to_i - max_dev - 30
    end_time = (calc_time + 3.hours).to_i
    stes = StopTimeEvent.for_stop_and_blocks_between(stop_id, vp_block_map.values.uniq, start_time, end_time)
    cas = stes.map do |ste|
      CalculatedArrival.new(ste, vp_blocks[ste.trip.block_id]) 
    end
    cas.reject do |ca| 
      ca.vehicle_already_past? ||
        (ca.comparison_time < calc_time.to_i)
    end
  end

  def initialize(ste, vp)
    @attributes = {}
    @attributes[:stop_time_id] = ste.stop_time_id
    @attributes[:vehicle_id] = vp.vehicle_id
    @attributes[:vehicle_trip_id] = vp.trip_id
    @attributes[:trip_id] = ste.trip.trip_id
    @attributes[:route_short_name] = ste.route.route_short_name
    @attributes[:route_name] = ste.route.route_long_name
    @attributes[:route_id] = ste.trip.route_id
    @attributes[:destination_stop_name] = ste.trip.last_stop_name
    @attributes[:trip_headsign] = ste.trip.trip_headsign
    @attributes[:scheduled_time] = ste.arrival_time
    @attributes[:predicted_deviation] = vp.predicted_deviation
    @attributes[:calculated_arrival_time] = ste.arrival_time - (vp.predicted_deviation * 60)
    @attributes[:calculated_time] = Time.at(@attributes[:calculated_arrival_time])
    @attributes[:scheduled_display_time] = Time.at(@attributes[:scheduled_time]).strftime("%l:%M%p")
    @attributes[:calculated_display_time] = Time.at(@attributes[:calculated_arrival_time]).strftime("%l:%M%p")
    @attributes[:message] = "#{@attributes[:calculated_display_time]} #{@attributes[:trip_headsign]} to #{ste.trip.last_stop_name}"

    @attributes[:vehicle_already_past] = (ste.trip.trip_id == vp.trip_id) && (ste.stop_time.stop_sequence < vp.previous_sequence) 
  end

  def vehicle_already_past?
    @attributes[:vehicle_already_past]
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

  def comparison_time
    @attributes[:calculated_arrival_time]
  end

  def arrival_time
    @attributes[:calculated_display_time]
  end

  def headsign
    @attributes[:trip_headsign]
  end
  def predicted_deviation
    @attributes[:predicted_deviation]
  end

  def destination
    @attributes[:destination_stop_name]
  end

  def on_time?
    predicted_deviation == 0
  end

  def adjusted_display_time
    @attributes[:calculated_diaplay_time]
  end

  def running_status
    dev = predicted_deviation
    if dev < 0
      "late"
    elsif dev > 0
      "early"
    else
      "on_time"
    end
  end
end
