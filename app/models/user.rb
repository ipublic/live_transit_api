class User < CouchRest::Model::Base
  self.database = CouchDatabases[:authentication]

  extend Devise::Models
  extend Devise::Orm::CouchRestModel::Hook

  devise :database_authenticatable, :token_authenticatable, :registerable, :validatable, :recoverable, :confirmable, :trackable
end
