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

    def cas(key, ttl=nil, options=nil, &block)
      ttl ||= @options[:expires_in]
      (value, cas) = perform(:cas, key)
      value = (!value || value == 'Not found') ? nil : value
      if value
        newvalue = block.call(value)
        perform(:set, key, Marshal.dump(newvalue), ttl, cas, options)
      end
    end

    def set(key, value, ttl=nil, options=nil)
      raise "Invalid API usage, please require 'dalli/memcache-client' for compatibility, see Upgrade.md" if options == true
      ttl ||= @options[:expires_in]
      perform(:set, key, Marshal.dump(value), ttl, 0, options)
    end


    def get(key, options=nil)
      resp = perform(:get, key)
      (!resp || resp == 'Not found') ? nil : resp
    end
  end
end
