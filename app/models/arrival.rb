class Arrival
  attr_reader :stop
  attr_reader :calculated_arrivals

  delegate :stop_name, :to => :stop

  def self.find(st_code, limit=5)
    stop = Stop.find_by_stop_code(st_code.to_s)
    return(nil) unless stop
    scheduled_arrivals = ScheduledArrival.find_for_stop_and_now(stop.stop_id)
    calculated_arrivals = CalculatedArrival.find_for_stop_and_now(stop.stop_id)
    Arrival.new(stop, scheduled_arrivals, calculated_arrivals, limit)
  end

  def initialize(stop, s_arrivals, c_arrivals, lim)
    @stop = stop
    @scheduled_arrivals = s_arrivals
    @calculated_arrivals = c_arrivals
    @limit = lim
  end

  def scheduled_arrivals
    @scheduled_arrivals.first(@limit)
  end

  def each_arrival
    base_time = Time.now
    ca_idx = @calculated_arrivals.inject({}) do |memo, ca|
      memo[ca[:stop_time_id]] = ca
      memo
    end
    all_cas = @scheduled_arrivals.first(@limit * 2).map { |sa| CompositeArrival.new(sa, ca_idx[sa[:stop_time_id]]) }
    composite_arrivals = all_cas.reject { |ca| ca.before?(base_time) }.first(@limit)
    composite_arrivals.each do |comp_a|
      yield comp_a
    end
  end
end
