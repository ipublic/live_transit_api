module Dalli
  class Client
    def replace(key, value, ttl=nil, options=nil)
      ttl ||= @options[:expires_in]
      perform(:replace, key, Marshal.dump(value), ttl, options)
    end

    def add(key, value, ttl=nil, options=nil)
      ttl ||= @options[:expires_in]
      perform(:add, key, Marshal.dump(value), ttl, options)
    end

    def get(key, options=nil)
      resp = perform(:get, key)
      (!resp || resp == 'Not found') ? nil : Marshal.load(resp)
    end
  end
end
