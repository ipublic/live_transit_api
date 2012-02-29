class CompositeArrival
  def initialize(s_arrival, c_arrival)
    @scheduled_arrival = s_arrival
    @calculated_arrival = c_arrival
  end

  def not_calculated?
    @calculated_arrival.nil?
  end

  def headsign
    "Route #{@scheduled_arrival[:route_short_name]} #{@scheduled_arrival[:trip_headsign]}"
  end

  def destination
    @scheduled_arrival[:destination_stop_name]
  end

  def arrival_time
    @scheduled_arrival[:scheduled_display_time]
  end

  def predicted_deviation
    @calculated_arrival["predicted_deviation"]
  end

  def before?(a_time)
    return(false) if not_calculated?
    @calculated_arrival[:calculated_time] < a_time
  end

  def on_time?
    return(true) if not_calculated?
    predicted_deviation == 0
  end

  def running_status
    return("on_time") if not_calculated?
    dev = predicted_deviation
    if dev < 0
      "late"
    elsif dev > 0
      "early"
    else
      "on_time"
    end
  end

  def adjusted_time
    @calculated_arrival[:calculated_time].strftime("%l:%M%p")
  end
end
