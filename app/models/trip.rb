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

  design do
    view :by_route_id_and_direction_id
    view :by_route_id
    view :by_shape_id
    view :by_trip_id
    spatial_view :by_route_and_date, :function =>
      "function(doc) {
        if (doc['type'] == 'Trip' && doc.schedules) {
          for (var i = 0; i < doc.schedules.length; i++) {
            var startd = parseFloat(doc.schedules[i].day_type.toString() + \".\" + doc.schedules[i].start_date.replace(/-/g, \"\"));
            var endd = parseFloat(doc.schedules[i].day_type.toString() + \".\" + doc.schedules[i].end_date.replace(/-/g, \"\"));
            var start_t = parseFloat(doc.route_id + \".\" + doc.start_time.replace(/:/g, \"\"));
            var end_t = parseFloat(doc.route_id + \".\" + doc.end_time.replace(/:/g, \"\"));

            emit(
            {
             type : 'LineString',
             coordinates : [
              [start_t, startd],
              [end_t, endd]
             ]
            },
            null);
          }
        }
      }"
    view :route_shapes, :map => 
      "function(doc) {
        if (doc.type && doc.type == 'Trip' && doc.schedules) {
          emit([doc.route_id, doc.shape_id], 1); 
        }
      }",
      :reduce =>
      "function(keys, values, rereduce) {
        return(sum(values));
      }"
  end

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(
      self,
      options.merge({:methods => :stops})
    ).serialize(&block)
  end

  def geometry
    ShapePoint.single_shape(:key => self.shape_id, :view => "by_shape_id").all
  end

  def to_json
    attributes.merge(:stops => stops).to_json
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
end
