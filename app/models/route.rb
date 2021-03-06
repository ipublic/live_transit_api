class Route < CouchRest::Model::Base
  property :route_id, String
  property :agency_id, String
  property :route_short_name, String
  property :route_long_name, String
  property :route_desc, String
  property :route_type, String
  property :route_url, String
  property :route_color, String
  property :route_text_color, String

  design do
    view :by_route_id
    view :by_route_short_name
    view :by_route_long_name
  end

  def self.route_collection(keys)
    route_ids = keys.uniq.sort
    route_ids_key = "route_collection_" + Digest::SHA512.hexdigest(route_ids.to_s)
    Rails.cache.fetch(route_ids_key) {
      Rails.logger.info "Fetching route_collection_#{route_ids.to_s} from couchdb!"
      Route.by_route_id(:keys => route_ids, :include_docs => true).docs
    }
  end

  def self.find_by_short_name(rt_sn)
    Route.by_route_short_name(:key => rt_sn).first
  end

  def trips
    return @trips if @trips
    found_trips = Trip.by_route_id(:key => self.route_id).all
    found_stops = StopTime.multiple_trip_stops(:keys => found_trips.map(&:trip_id), :view => :for_trip_id).all
    found_trips.each do |ft|
      ft.stops = found_stops[ft.trip_id]
    end
    @trips = found_trips
  end

  def shapes
    return @shapes if @shapes
    routes_shapes = Trip.route_shapes(:startkey => [self.route_id, ""], :endkey => [self.route_id, "\u00FF"], :reduce => true, :group => true).keys.map(&:last)
    @shapes = ShapePoint.many_shapes(:keys => routes_shapes, :view => :by_shape_id).all
  end

  def full_json(encoder)
    attributes.merge(:trips => trips.as_json(:encoder => encoder), :shapes => shapes.as_json(:encoder => encoder)).as_json
  end

  def as_json(opts = {})
    encoder = opts[:encoder]
    if (!encoder.nil? && encoder.kind_of?(LinkedEncoder))
      resolver = encoder.resolver
      attributes.merge(:uri => resolver.url_for(self)).as_json
    else
      super(opts)
    end
  end

  def to_json(options = {})
    resolver = options[:url_resolver]
    if resolver
      attributes.merge(:link => resolver.url_for(self)).to_json
    else
      super
    end
  end

  def to_geojson
    {
      :type => "FeatureCollection",
      :features => shapes.map do |shape|
        {
          :type => "Feature",
          :properties => {
            :route_short_name => self.route_short_name,
            :route_long_name => self.route_long_name,
            :route_id => self.route_id,
            :shape_id => shape["shape_id"]
          },
          :geometry => shape
        }
      end
    }.to_json
  end

  def to_param
    self.route_id
  end
end
