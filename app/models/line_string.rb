class LineString < Geometry
  property :coordinates, [Coordinate]

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options.merge({:type => "LineString"})).serialize(&block)
  end

end
