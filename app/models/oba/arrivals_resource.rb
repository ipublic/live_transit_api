class Oba::ArrivalsResource
  URL = "http://localhost:8080/api/where/arrivals-and-departures-for-stop/"
  AGENCY_ID = "MCRO_"

  PARAMS = {
    :key => "TEST",
    :minutesAfter => "360"
  }

  attr_reader :stop_name

  def initialize(s_name, s_id, limit = 5)
    @limit = limit
    stop_resource = "#{AGENCY_ID}#{s_id}.xml"
    uri = URI(URL + stop_resource)
    uri.query = URI.encode_www_form(PARAMS)
    res = Net::HTTP.get_response(uri)
    as_and_ds = []
    doc = Nokogiri::XML(res.body)
    doc.xpath("//arrivalAndDeparture[departureEnabled = 'true']").each do |item|
      as_and_ds.push(Oba::Departure.new(AGENCY_ID, item))
    end
    @arrivals = as_and_ds
    @stop_name = s_name
  end

  def each_arrival
    @arrivals.sort.first(@limit).each do |arr|
      yield arr
    end
  end

  def self.find(st_code, limit = 5)
    stop = Stop.find_by_stop_code(st_code.to_s)
    return nil unless stop
    Oba::ArrivalsResource.new(stop.stop_name, stop.stop_id, limit)
  end

end
