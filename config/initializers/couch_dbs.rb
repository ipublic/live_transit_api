class CouchDatabases

  def self.[]=(key, val)
    @dbs ||= {}
    @dbs[key] = val
  end

  def self.[](key)
    @dbs ||= {}
    @dbs[key]
  end

end

# The below is shamelessly ganked from the OpenMedia project.
begin
  db_profiles = YAML::load(ERB.new(IO.read(Rails.root.to_s + "/config/couchdb.yml")).result)

  db_profiles.each_pair do |env, couchdb_config|
    unless [:development, :production, :test].include?(env.to_sym)
      host      = couchdb_config["host"]      || 'localhost'
      port      = couchdb_config["port"]      || '5984'
      database  = couchdb_config["database"] || ''
      username  = couchdb_config["username"]
      password  = couchdb_config["password"]
      ssl       = couchdb_config["ssl"]       || false
      db_prefix = couchdb_config["prefix"] || ""
      db_suffix = couchdb_config["suffix"] || ""

      protocol = ssl ? 'https://' : 'http://'
      authorized_host = (username.blank? && password.blank?) ? host : "#{CGI.escape(username)}:#{CGI.escape(password)}@#{host}"
      server = CouchRest::Server.new([protocol, authorized_host, ":", port].join)

      CouchDatabases[env.to_sym] = server.database!([db_prefix, database, db_suffix].join(" ").strip.gsub(/\s+/, "_"))
    end
  end
rescue

  raise "There was a problem with your config/couchdb.yml file. Check and make sure it's present and the syntax is correct."
end
