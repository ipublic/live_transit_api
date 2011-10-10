class Coordinate < Array

  def attributes
    {
      'lon' => self[0],
      'lat' => self[1]
    }
  end

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options.merge({:root => "coordinate"})).serialize(&block)
  end

end
