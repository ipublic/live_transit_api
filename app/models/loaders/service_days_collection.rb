require 'set'

class Loaders::ServiceDaysCollection
  ServiceDay = Struct.new(:service_id, :date)

  DAYS = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  attr_reader :service_days

  def initialize
    @service_days = Set.new
  end

  def process(opts = {})
    start_date = parse_out_date(opts[:start_date])
    end_date = parse_out_date(opts[:end_date])
    service_id = opts[:service_id]
    days = []
    DAYS.each_with_index do |day, idx|
      if opts[day].to_i == 1
        days.push(idx)
      end
    end
    (start_date..end_date).each do |day|
      if days.include?(day.wday)
        @service_days = @service_days.add(ServiceDay.new(service_id, day.to_time_in_current_zone))
      end
    end
  end

  def process_exception(opts = {})
    time = parse_out_date(opts[:date]).to_time_in_current_zone
    service_id = opts[:service_id]
    service_removed = opts[:exception_type].to_i == 2
    if service_removed
      @service_days = @service_days.delete(ServiceDay.new(service_id, time))
     else
      @service_days = @service_days.add(ServiceDay.new(service_id, time))
    end
  end

  def enumerated_days
    @service_days.map { |sd| [sd.service_id, sd.date.to_i] }
  end

  def parse_out_date(val)
    Time.zone.parse(val, "%Y%m%d").to_date
  end
end
