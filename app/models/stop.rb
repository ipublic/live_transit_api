class Stop < CouchRest::Model::Base
  property :stop_id, String
  property :stop_code, String
  property :stop_name, String
  property :stop_lat, String
  property :stop_lon, String
  property :zone_id, String
  property :stop_url, String
  property :location_type, String
  property :parent_station, String
  property :geometry, Point

  design do
    view :by_stop_code
  end
  
  include XmlSerializableDocument

  def self.find_by_stop_code(sc)
    self.by_stop_code.key(sc).first
  end

  def stop_times
    StopTime.single_stop_stops(:key => self.stop_id, :view => :for_stop_id).all
  end

  def to_param
    self.stop_code
  end

  def as_geojson 
    {
      :type => "Feature",
      :properties => {
        :stop_id => self.stop_id,
        :stop_code => self.stop_code
      },
      :geometry => self.geometry
    }
  end
end
