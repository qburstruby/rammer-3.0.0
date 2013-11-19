class Oauth2Authorization < ActiveRecord::Base
  belongs_to :client, :class_name => 'Oauth2Client'

  def get_token(owner,client, attributes = {})
    return nil unless owner and client
        @instance = owner.oauth2_authorization(client,owner) ||
            Oauth2Authorization.new do |authorization|
                authorization.oauth2_resource_owner_id  = owner.id
                authorization.oauth2_client_id = client.id
            end
        case attributes[:response_type]
            when 'code'
              @instance.code ||= create_code(client)
            when 'token'
              @instance.access_token  ||= create_access_token
              @instance.refresh_token ||= create_refresh_token(client)
        end

        if @instance.expires_at.nil?        
            @instance.expires_at = attributes[:duration].present? ? Time.now + attributes[:duration].to_i : nil         
        elsif attributes[:invalidate]
            @instance.expires_at = Time.now
        end

        if @instance.scope.nil?
          @instance.scope = attributes[:scope].present? ? attributes[:scope] : nil        
        elsif attributes[:scope].present?
          @instance.scope += "," + attributes[:scope] unless @instance.scope.include? attributes[:scope]
        end

        @instance.save
        return @instance

        rescue Object => error
            raise error
  end

  def api_response(redirect_uri)
    redirect_to_url = self.build_url(redirect_uri,"token") 
    self.refresh_access_token if self.expired? 
    return redirect_to_url
  end

  def refresh_access_token
    self.expires_at = Time.now + 3600   
    save
  end

  def create_code(client)
    Songkick::OAuth2.generate_id do |code|
        return code
    end
  end

  def create_access_token
    hash = nil
    Songkick::OAuth2.generate_id do |token|
      hash = Songkick::OAuth2.hashify(token)         
    end
    return hash
  end

  def create_refresh_token(client)
    verified_client = Oauth2Client.find_by_client_id(client.client_id)
    Songkick::OAuth2.generate_id do |refresh_token|
      if verified_client
          hash = Songkick::OAuth2.hashify(refresh_token)
        else
            hash = nil
          end
    end
      return hash
  end

  def scopes
    scopes = scope ? scope.split(/\s+/) : []
    scopes = attributes[:scope]
    Set.new(scopes).to_s
  end

  def in_scope?(request_scope)
    [*request_scope].all?(&scopes.method(:include?))
  end

  def expired?
    return false unless expires_at
    expires_at < Time.now
  end

  def generate_access_token
    self.access_token ||= self.create_access_token
    save && access_token
  end

  def generate_code
    self.code ||= self.create_code(client)
    save && code
  end

  def self.error_response(error)
    error_response = {
      :error => "Unauthorized access",
      :description => error,
      :status => 401
    }
  end

  def build_url(redirect_uri,type)
    path = redirect_uri.split('#',2).first if redirect_uri.include? "#"
    path = redirect_uri.split('?',2).first if redirect_uri.include? "?"
    case type
    when "token"
      return path + "?access_token=#{self.access_token}"
    when "code"
      return path + "?request_token=#{self.code}"
    end
  end

  def redirect(auth)
    return auth.redirect_uri.split('#',2).first
  end

end