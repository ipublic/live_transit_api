class Trip < CouchRest::Model::Base
  property :trip_id, String
  property :route_id, String
  property :shape_id, String
  property :service_id, String
  property :trip_headsign, String
  property :trip_short_name, String
  property :direction_id, Integer
  property :schedules, [Hash]
  property :start_time, String
  property :end_time, String
  property :first_stop_name, String
  property :last_stop_name, String

  attr_writer :stops
  attr_reader :shape

  design do
    view :by_route_id_and_direction_id
    view :by_route_id
    view :by_shape_id
    view :by_trip_id
    spatial_view :by_route_and_date, :function => CouchDocLoader["_design/Trip/spatial/by_route_and_date.js"]
    view :route_shapes, :map => CouchDocLoader["_design/Trip/views/route_shapes/map.js"], :reduce => CouchDocLoader["_design/Trip/views/route_shapes/reduce.js"]
  end

  def to_xml(options = {}, &block)
    additional_options = (options[:include] == :geometry) ? { :methods => [:stops, :geometry] } : { :methods => :stops }
    ActiveModel::Serializers::Xml::Serializer.new(
      self,
      options.merge(additional_options)
    ).serialize(&block)
  end

  def geometry
    ShapePoint.single_shape(:key => self.shape_id, :view => "by_shape_id").all
  end

  def to_json(options = {})
    additional_options = { :stop_times => stops }
    if options[:include] == :geometry
      additional_options[:geometry] = geometry
    end
    attributes.merge(additional_options).to_json
  end

  def full_json(enc)
   encoded_stops = stops.map do |stp|
     stp.merge({
        :stop => { 
          :link => enc.resolver.url_for(:controller => :stops, :action => :show, :id => stp["stop_code"])
        }
     })
   end
   self.attributes.merge({
      :stops => encoded_stops.as_json,
      :route => {
        :link => enc.resolver.url_for(:controller => :routes, :action => :show, :id => self.route_id)
      },
      :geometry => geometry.as_json
    }).as_json
  end

  def as_json(opts = {})
    encoder = opts[:encoder]
    additional_options = { }
    if opts[:include] == :geometry
      additional_options[:geometry] = geometry
    end
    if (!encoder.nil? && encoder.kind_of?(LinkedEncoder))
      resolver = encoder.resolver
      additional_options[:stop_times] = stops.map do |stp|
        stp.merge({
        :stop => { 
          :link => resolver.url_for(:controller => :stops, :action => :show, :id => stp["stop_code"]) 
        }
        })
      end
      attributes.merge({:link => resolver.url_for(self)}.merge(additional_options)).as_json
    else
      super(opts)
    end
  end

  def stops
    @stops ||= StopTime.single_trip_stops(:key => self.trip_id, :view => "for_trip_id").all
  end

  def to_geojson
    {
      :type => "FeatureCollection",
      :features => stops.map(&:to_geojson) + [{
        :name => "Trip ##{self.trip_id}",
        :properties => {
          :trip_id => self.trip_id,
          :route_id => self.route_id,
          :shape_id => self.shape_id,
          :type => "Trip"
        },
        :geometry => self.geometry
      }]
    }.to_json
  end

  def to_param
    self.trip_id
  end
end
