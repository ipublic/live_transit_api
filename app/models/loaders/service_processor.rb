require 'csv'

class Loaders::ServiceProcessor
  attr_reader :enumerated_services

  def initialize(service_data, exceptions_data)
    @service_records = ServiceDaysCollection.new
    CSV.foreach(service_data, {:headers => true, :header_converters => :symbol}) do |row|
      @service_records.process(
          row.to_hash
      )
    end
    CSV.foreach(exceptions_data, {:headers => true, :header_converters => :symbol}) do |row|
      @service_records.process_exception(
          row.to_hash
      )
    end
  end

  def enumerated_days
    @service_records.enumerated_days
  end

end
