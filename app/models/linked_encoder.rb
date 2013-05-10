class LinkedEncoder
  attr_reader :resolver

  def initialize(res, opts = {})
    @options = opts
    @resolver = res
  end

  def as_json(obj)
    obj.as_json(@options.merge({ :encoder => self}))
  end

end
