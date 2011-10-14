class ShapePoint < CouchRest::Model::Base
  property :shape_id, String
  property :shape_dist_traveled, Float
  property :shape_pt_lat, Float
  property :shape_pt_lon, Float
  property :shape_pt_sequence, Integer

  design do
    view :by_shape_id, :map =>
    "function(doc) {
      if (doc.type && doc.type == \"ShapePoint\") {
        emit(doc.shape_id, { 
          'sequence': doc.shape_pt_sequence,
          'coordinates' : [doc.shape_pt_lon, doc.shape_pt_lat]
          });
      }
    }"
    list :many_shapes, :function => CouchDocLoader["_design/ShapePoint/lists/many_shapes.js"]
    list :single_shape, :function =>
    "function(head, req) {
      start({
        'headers': {
          'Content-Type': 'application/json'
        }
      });
      var row = null;
      var shape = {
        'shape_id' : null,
        'type' : 'LineString',
        'coordinates' : []
      };
      while (row = getRow()) {
        shape.shape_id = row.key;
        shape.coordinates[row.value.sequence - 1] = row.value.coordinates
      }
      send(toJSON(shape));
    }"
  end
end
