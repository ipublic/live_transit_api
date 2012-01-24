class Arrival
  attr_reader :stop
  attr_reader :scheduled_arrivals
  attr_reader :calculated_arrivals

  def self.find(st_code, limit=5)
    stop = Stop.by_stop_code(:key => st_code).first
    scheduled_arrivals = ScheduledArrival.find_for_stop_and_now(stop.stop_id)[0..limit]
    calculated_arrivals = CalculatedArrival.find_for_stop_and_now(stop.stop_id)[0..limit]
    Arrival.new(stop, scheduled_arrivals, calculated_arrivals)
  end

  def initialize(stop, s_arrivals, c_arrivals)
    @stop = stop
    @scheduled_arrivals = s_arrivals
    @calculated_arrivals = c_arrivals
  end
end
