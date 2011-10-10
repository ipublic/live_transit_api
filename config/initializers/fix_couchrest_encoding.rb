class Hash
  def to_json
    MultiJson.encode(self)
  end
end

class Array
  def to_json
    MultiJson.encode(self)
  end
end
