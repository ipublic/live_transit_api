class StopArrival

  attr_reader :stop_time_id, :vehicle_id, :trip_id, :trip_headsign, :stop_name, :stop_id,
    :stop_code, :is_calculated, :route_long_name, :route_short_name, :route_id,
    :scheduled_arrival, :scheduled_departure, :vehicle_has_passed, :arrival_time, :departure_time

  def self.find_for_now
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
    block_ids = vp_block_map.values.uniq
    vp_blocks = vp.inject({}) do |memo, vp|
      memo[vp_block_map[vp.trip_id]] = vp
      memo
    end
    max_dev = ((vp.map { |v| v.predicted_deviation.abs }.max) || 0) * 60
    start_time = calc_time.to_i - max_dev - 30
    end_time = (calc_time + 2.hours).to_i
    now_cutoff = calc_time.to_i - 10
    all_events = StopTimeEvent.for_arrival_time_with_blocks(now_cutoff, start_time, end_time, block_ids)
    all_events.inject([]) do |memo,ste| 
      stop_arr = StopArrival.new(ste, vp_blocks[ste.block_id])
      if !(stop_arr.vehicle_has_passed || stop_arr.happened_before(now_cutoff))
        memo << stop_arr
      end
      memo
    end
  end

  def initialize(ste, vehicle)
    @stop_time_id = ste.stop_time_id
    @route_long_name = ste.route.route_long_name
    @route_short_name = ste.route.route_short_name
    @route_id = ste.route.id
    @trip_id = ste.stop_time.trip.trip_id
    @trip_headsign = ste.stop_time.trip.trip_headsign
    @stop_code = ste.stop.stop_code
    @stop_id = ste.stop_id
    @scheduled_arrival = ste.arrival_time
    @scheduled_departure = ste.departure_time
    @is_calculated = !vehicle.nil?
    @arrival_time = ste.arrival_time
    @departure_time = ste.departure_time
    @vehicle_has_passed = false
    if is_calculated
      @vehicle_id = vehicle.vehicle_id
      @arrival_time = ste.arrival_time - (vehicle.predicted_deviation * 60)
      @departure_time = ste.departure_time - (vehicle.predicted_deviation * 60)
      @vehicle_has_passed = (ste.stop_time.trip.trip_id == vehicle.trip_id) && (ste.stop_time.stop_sequence < (vehicle.previous_sequence || 0)) 
    end
  end

  def happened_before(now_cutoff)
    @arrival_time < now_cutoff
  end
end
