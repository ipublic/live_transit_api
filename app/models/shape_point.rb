class ShapePoint < CouchRest::Model::Base
  property :shape_id, String
  property :shape_dist_traveled, Float
  property :shape_pt_lat, Float
  property :shape_pt_lon, Float
  property :shape_pt_sequence, Integer

  design do
    view :by_shape_id, :map => CouchDocLoader["_design/ShapePoint/views/by_shape_id/map.js"]
    list :many_shapes, :function => CouchDocLoader["_design/ShapePoint/lists/many_shapes.js"]
    list :single_shape, :function => CouchDocLoader["_design/ShapePoint/lists/single_shape.js"]
  end

end
