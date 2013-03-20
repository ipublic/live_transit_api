class Arrival
  attr_reader :stop
  attr_reader :calculated_arrivals

  delegate :stop_name, :to => :stop

  def self.find(st_code, limit=5)
    stop = Stop.find_by_stop_code(st_code.to_s)
    return(nil) unless stop
#    RubyProf.start
    scheduled_arrivals = ScheduledArrival.find_for_stop_and_now(stop.stop_id, limit)
    calculated_arrivals = CalculatedArrival.find_for_stop_and_now(stop.stop_id)
#    calculated_arrivals = CalculatedArrival.find_for_stop_and_now(stop.stop_id)
#    res = RubyProf.stop
#    printer = RubyProf::GraphHtmlPrinter.new(res)
#    rf = File.open("profile.html", 'w')
#    printer.print(rf)
#    rf.close
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
    sa_idx = @scheduled_arrivals.inject({}) do |memo, sa|
      memo[sa[:stop_time_id]] = sa
      memo
    end
    ca_idx = @calculated_arrivals.inject(sa_idx) do |memo, ca|
      memo[ca[:stop_time_id]] = ca
      memo
    end
    composite_arrivals = ca_idx.values
    composite_arrivals.sort_by(&:comparison_time).first(@limit).each do |comp_a|
      yield comp_a
    end
  end
end
