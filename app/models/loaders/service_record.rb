class Loaders::ServiceRecord
  DAYS = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  attr_reader :service_ranges

  def initialize(opts = {})
    @service_ranges = []
    @service_id = opts[:service_id]
    @start_date = parse_out_date(opts[:start_date])
    @end_date = parse_out_date(opts[:end_date])
    DAYS.each do |day|
      if opts[day].to_i == 1
        @service_ranges.push({
          :service_id => @service_id,
          :start_date => @start_date,
          :end_date => @end_date,
          :day_type => DAYS.index(day)
        })
      end
    end
  end

  def parse_out_date(val)
    val.kind_of?(Date) ? val : Time.zone.parse(val, "%Y%m%d")
  end
end
