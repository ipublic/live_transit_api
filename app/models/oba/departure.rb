class Oba::Departure
  attr_reader :deviation, :trip_headsign, :route_name

  def initialize(a_id, ng_node)
    @predicted = (ng_node.xpath("predicted").first.content == "true")
    @scheduled_time = Time.at(ng_node.xpath("scheduledDepartureTime").first.content.to_i / 1000)
    @trip_headsign = ng_node.xpath("tripHeadsign").first.content
    @route_name = ng_node.xpath("routeLongName").first.content
    if @predicted
      @deviation = ng_node.xpath("tripStatus/scheduleDeviation").first.content.to_i / 60
      @calculated_time = Time.at(ng_node.xpath("predictedDepartureTime").first.content.to_i / 1000)
    else
      @deviation = 0
    end
  end

  def running_status
    return "on_time" if on_time?
    (deviation > 0) ? "late" : "early"
  end

  def time
    predicted? ? @calculated_time : @scheduled_time
  end

  def display_time
    time.strftime("%l:%M%p")
  end

  def predicted?
    @predicted
  end

  def on_time?
    (deviation == 0)
  end

  def <=>(other)
    self.time <=> other.time
  end

  include Comparable

end
