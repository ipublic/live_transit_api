class Loaders::ServiceDayRange
  attr_reader :start_date
  attr_reader :end_date
  attr_reader :day_type
  attr_reader :service_id
  attr_reader :range

  def initialize(opts = {})
    # This should really be extracted, but for now I'm a little lazy
    @service_id = opts[:service_id]
    @start_date = opts[:start_date]
    @end_date = opts[:end_date]
    @day_type = opts[:day_type]
    @range = (@start_date..@end_date)
  end

  def remove_exception(service_exception)
    return [self] unless self.includes?(service_exception)
    return [] if (self.end_date - self.start_date == 0)
    if self.end_date == service_exception.date
      [new_range_for_dates(@start_date, @end_date - 1)]
    elsif self.start_date == service_exception.date
      [new_range_for_dates(@start_date + 1, @end_date)]
    else
      [
        new_range_for_dates(@start_date, service_exception.date - 1),
        new_range_for_dates(service_exception.date + 1, @end_date)
      ]
    end
  end

  def new_range_for_dates(s_date, e_date)
      Loaders::ServiceDayRange.new({
        :service_id  => @service_id,
        :day_type => @day_type,
        :start_date => s_date,
        :end_date => e_date
      })
  end

  def includes?(service_exception)
    @service_id == service_exception.service_id &&
      @day_type == service_exception.day_type &&
      @range.include?(service_exception.date)
  end

  def ==(other)
    return false unless other.kind_of?(self.class)
    @service_id == other.service_id &&
      @day_type == other.day_type &&
      @start_date == other.start_date &&
      @end_date == other.end_date
  end

end
