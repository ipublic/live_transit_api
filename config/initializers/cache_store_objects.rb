=begin
module Dalli
  class Server
    def serialize(key, value, options=nil)
      marshalled = true
      value = unless options && options[:raw]
                begin
                  Marshal.dump(value)
                rescue => ex
                  # Marshalling can throw several different types of generic Ruby exceptions.
                  #           # Convert to a specific exception so we can special case it higher up the stack.
                  exc = Dalli::MarshalError.new(ex.message)
                  exc.set_backtrace ex.backtrace
                  raise exc
                end
              else
                marshaled = false
                value.to_s
              end
      compressed = false
      if @options[:compression] && value.bytesize >= COMPRESSION_MIN_SIZE
        value = Zlib::Deflate.deflate(value)
        compressed = true
      end
      flags = 0
      flags |= FLAG_COMPRESSED if compressed
      flags |= FLAG_MARSHALLED if marshalled
      [value, flags]
    end
    def deserialize(value, flags)
      value = Zlib::Inflate.inflate(value) if (flags & FLAG_COMPRESSED) != 0
      value = Marshal.load(value) if (flags & FLAG_MARSHALLED) != 0
      value
    rescue TypeError, ArgumentError
      raise DalliError, "Unable to unmarshal value: #{$!.message}"
    rescue Zlib::Error
      raise DalliError, "Unable to uncompress value: #{$!.message}"
    end
  end
end
=end
