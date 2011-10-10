class Point < Geometry
  property :coordinates, Coordinate

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options.merge({:type => "Point"})).serialize(&block)
  end
end
