class CompositeArrival < SignArrival
  def initialize(s_arrival, c_arrival)
    @scheduled_arrival = s_arrival
    @calculated_arrival = c_arrival
  end

  def reference_arrival
    @scheduled_arrival
  end
end
