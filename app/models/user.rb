class User < CouchRest::Model::Base
  self.database = CouchDatabases[:authentication]
end
