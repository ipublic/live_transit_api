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

  def as_json(opts = {})
    encoder = opts[:encoder]
    if (!encoder.nil? && encoder.kind_of?(LinkedEncoder))
      resolver = encoder.resolver
      attributes.merge({ :link => resolver.url_for(self) }).as_json
    else
      super(opts)
    end
  end

  def full_json(enc)
   encoded_times = stop_times.map do |stp|
     stp.merge({
        :trip => { 
          :link => enc.resolver.url_for(:controller => :trips, :action => :show, :id => stp["trip_id"])
        },
        :route => { 
          :link => enc.resolver.url_for(:controller => :routes, :action => :show, :id => stp["route_id"])
        }
     })
   end
   attributes.merge(:stop_times => encoded_times.as_json)
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
