class SignArrival

  def self.calculate(s_arrival, c_arrival)
    if c_arrival.nil?
      ScheduledOnlyArrival.new(s_arrival)
    elsif s_arrival.nil?
      CalculatedOnlyArrival.new(c_arrival)
    else
      CompositeArrival.new(s_arrival, c_arrival)
    end
  end

  def headsign
    "Route #{reference_arrival[:route_short_name]} #{reference_arrival[:trip_headsign]}"
  end

  def destination
    reference_arrival[:destination_stop_name]
  end

  def arrival_time
    reference_arrival[:scheduled_display_time]
  end

  # ALL of these must be over-ridden in ScheduleOnlyArrival
  def not_calculated?
    false
  end

  def time
    @calculated_arrival[:calculated_time]
  end

  def predicted_deviation
    @calculated_arrival["predicted_deviation"]
  end

  def on_time?
    predicted_deviation == 0
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

  def adjusted_display_time
    @calculated_arrival[:calculated_time].strftime("%l:%M%p")
  end
end
