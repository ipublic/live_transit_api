class ScheduledOnlyArrival < SignArrival

  def initialize(s_arrival)
    @scheduled_arrival = s_arrival
  end

  def reference_arrival
    @scheduled_arrival
  end

  def not_calculated?
    true
  end

  def on_time?
    true
  end

  def running_status
    "on_time"
  end

  def time
    @scheduled_arrival[:scheduled_time]
  end
end
