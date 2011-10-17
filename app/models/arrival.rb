class Arrival
  attr_reader :attributes


  def self.find(st_code, limit=5)
    stop = Stop.by_stop_code(:key => st_code).first
    Arrival.new(stop, ScheduledArrival.find_for_stop_and_now(stop.stop_id)[0..limit])
  end

  def initialize(stop, scheduled_arrivals)
    @attributes = {}
    @attributes[:stop] = stop
    @attributes[:scheduled_arrivals] = scheduled_arrivals
  end

  def to_json
    attributes.to_json
  end

  def to_xml(opts = {})
    attributes.to_xml(opts.merge({:root => "arrival"}))
  end
end
