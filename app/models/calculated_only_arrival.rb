class CalculatedOnlyArrival < SignArrival
  def initialize(c_arrival)
    @calculated_arrival = c_arrival
  end

  def reference_arrival
    @calculated_arrival
  end
end
