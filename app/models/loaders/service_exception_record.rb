class Loaders::ServiceExceptionRecord
  attr_reader :date
  attr_reader :service_id
  attr_reader :day_type
  
  def initialize(opts = {})
    @date = parse_out_date(opts[:date])
    @service_id = opts[:service_id]
    @service_removed = opts[:exception_type].to_i == 2
    @day_type = @date.wday
  end

  def service_removed?
    @service_removed
  end

  def parse_out_date(val)
    val.kind_of?(Date) ? val : Date.strptime(val, "%Y%m%d")
  end
end
