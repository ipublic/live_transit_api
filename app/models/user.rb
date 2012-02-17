class User < CouchRest::Model::Base
  self.database = CouchDatabases[:authentication]

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :timeoutable

  design do
    view :by_email
    view :by_confirmation_token
    view :by_authentication_token
  end

  before_create :generate_auth_token
  after_save :clear_auth_token_cache

  def generate_auth_token
    auth_token = SecureRandom.base64(40).tr('+/=lIO0', 'pqrsxyz')
    tokens = User.by_authentication_token(:include_docs => true).map(&:authentication_token)
    while tokens.include?(auth_token)
      auth_token = SecureRandom.base64(40).tr('+/=lIO0', 'pqrsxyz')
    end
    self.authentication_token = auth_token
  end

  def clear_auth_token_cache
    Rails.cache.delete("devise_by_authentication_token_#{self.authentication_token.to_s}")
  end
end
