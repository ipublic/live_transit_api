module XmlSerializableDocument
  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options).serialize(&block)
  end
end
