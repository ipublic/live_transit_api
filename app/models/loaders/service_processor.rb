require 'csv'

class Loaders::ServiceProcessor
  attr_reader :service_records
  attr_reader :exception_records
  attr_reader :services
  attr_reader :keyed_services
  attr_reader :enumerated_services

  def initialize(service_data, exceptions_data)
    @service_records = []
    CSV.foreach(service_data, {:headers => true, :header_converters => :symbol}) do |row|
      @service_records.push(
        Loaders::ServiceRecord.new(
          row.to_hash
        )
      )
    end
    @exception_records = []
    CSV.foreach(exceptions_data, {:headers => true, :header_converters => :symbol}) do |row|
      @exception_records.push(
        Loaders::ServiceExceptionRecord.new(
          row.to_hash
        )
      )
    end
    @services = normalize_services(@service_records, @exception_records)
    @keyed_services = Hash.new([])
    keyed_raw_services = @services.inject(Hash.new([])) do |m, sr|
      m[sr.service_id] = m[sr.service_id] + [sr]
      m
    end
    @services.each do |serv|
      @keyed_services[serv.service_id] = @keyed_services[serv.service_id] + [
        ScheduleDayRange.new({
          :start_date => serv.start_date,
          :end_date => serv.end_date,
          :day_type => serv.day_type
        })
      ]
    end
    @enumerated_services = {}
    keyed_raw_services.each_pair do |k, v|
      @enumerated_services[k] = enumerate_service_days(v)
    end
  end

  def normalize_services(service_records, service_exceptions)
    service_removals, service_additions = service_exceptions.partition { |se| se.service_removed? }
    service_day_ranges = service_records.map(&:service_ranges).flatten.map { |sr| Loaders::ServiceDayRange.new(sr) }
    ranges_with_removals = service_removals.inject(service_day_ranges) do |memo, sr|
      memo.map { |sdr| sdr.remove_exception(sr) }.flatten
    end
    all_ranges = ranges_with_removals + (service_additions.map do |sa|
      Loaders::ServiceDayRange.new({
       :service_id => sa.service_id,
       :start_date => sa.date,
       :end_date => sa.date,
       :day_type => sa.day_type
      })
    end)
    all_ranges
  end

  def enumerate_service_days(day_ranges)
    first_day = day_ranges.min { |r| r.start_date }.start_date
    last_day = day_ranges.max { |l| l.end_date }.end_date
    days_range = (first_day..last_day)
    days_range.select do |aday|
      day_ranges.any? { |dr| dr.includes_date?(aday) }
    end
    days_range.map { |d| d.to_time.to_i }
  end
end
