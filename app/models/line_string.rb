class LineString < Geometry
  property :coordinates, [Coordinate]

  design do
    view :by_shape_id
  end

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options.merge({:type => "LineString"})).serialize(&block)
  end

end
