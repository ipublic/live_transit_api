class LiveTransitSystemStatus
  attr_reader :report_time
  attr_reader :vehicle_reporting_buckets

  def initialize
    @report_time = Time.now
    buckets = {
     "Within 1 Minute" => [1, 0],
     "1-2 Minutes" => [2, 1],
     "2-3 Minutes" => [3, 2],
     "3-4 Minutes" => [4, 3],
     "4-5 Minutes" => [5,4],
     "5 Minutes - Last Hour" => [60,5]
    }
    @bucket_filters = buckets.inject([]) do |h,(k,v)|
      h[v.last] = [k, @report_time - v.first.minutes, @report_time - v.last.minutes]
      h
    end
    @vehicles = VehiclePosition.all(:include_docs => true).docs
    @vehicle_reporting_buckets = @bucket_filters.map do |bf|
       [
         bf[0],
         (@vehicles.count do |v|
           (bf[1] <= v.latest_report_time) && (v.latest_report_time < bf[2])
         end)
       ]
    end
  end

end
