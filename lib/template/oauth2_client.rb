class Oauth2Client < ActiveRecord::Base
  has_many :oauth2_authorizations
  attr_accessible :name, :client_id, :client_secret_hash, :redirect_uri
  validates_presence_of :name, :client_id, :client_secret_hash, :redirect_uri
  validates_uniqueness_of :client_id

  before_validation :generate_keys, :on => :create

  def self.register(params)
    if @client = Oauth2Client.find_by_name(params.name)
      error = "Client already exists."
      error_message = Oauth2Authorization.error_response(error)
      return error_message, false
    else
      @oauth2_client = Oauth2Client.create!(:name => params.name, :redirect_uri => params.redirect_uri)          
      string = "#{@oauth2_client.client_id}:#{@oauth2_client.client_secret_hash}"
      @oauth2_client.update_attribute(:basic_code, Base64.encode64(string))
      redirect_url = @oauth2_client.redirect_to_url(params.callback_url)
      return redirect_url, true
    end
  end

  def self.valid_authorization?(params)
    authorization_decoded = Base64.decode64(params.authorization)   
    @client = Oauth2Client.find_by_client_id(params.client_id)
    if @client 
      unless authorization_decoded.eql?("#{@client.client_id}:#{@client.client_secret_hash}")
        return false, "present"
      else
        return true, "present"
      end
    else
      return false, "absent"
    end   
  end

  def self.grant_code(params,env)
      @owner  = Owner.find_by_username(params.username)
      @owner = Owner.create(:username => params.username) if @owner.nil?

    @oauth2 = Songkick::OAuth2::Provider.parse(@owner, env)  
    if @oauth2.valid?    
        @auth = Songkick::OAuth2::Provider::Authorization.new(@owner, params)
        @authenticated_owner = Oauth2Authorization.find_by_oauth2_resource_owner_id_and_oauth2_client_id(@owner.id,@auth.client.id)
        unless @authenticated_owner
          @oauth2_authorization_instance = Oauth2Authorization.new()
          @instance = @oauth2_authorization_instance.get_token(@auth.owner, @auth.client,
                    :response_type => "code",
                    :scope => params["scope"].present? ? params["scope"] : nil,
                    :duration => params["duration"].present? ? params["duration"] : 3600)   
        else
          @instance = @authenticated_owner
        end
        if @instance.code.nil?                
          error_message = Oauth2Authorization.error_response(@oauth2.error_description)
          return error_message, false   
        else
          redirect_to_url = @instance.build_url(@auth.redirect_uri,"code") 
          @instance.refresh_access_token if @instance.expired?  
          return redirect_to_url, true                      
        end  
    else
      error_message = Oauth2Authorization.error_response(@oauth2.error_description) 
      return error_message, false  
    end
  end

  def self.grant_access(params,env,request_type)
    if request_type == "user"
      @owner  = Owner.find_by_username(params.username)
      @owner = Owner.create(:username => params.username) if @owner.nil?
    else
      @owner  = Owner.find_by_username(params.host_name+"_bearer")
      @owner = Owner.create(:username => params.host_name+"_bearer") if @owner.nil?
    end

    @oauth2 = Songkick::OAuth2::Provider.parse(@owner, env)  
    if @oauth2.valid?    
        @auth = Songkick::OAuth2::Provider::Authorization.new(@owner, params)
        @authenticated_owner = Oauth2Authorization.find_by_oauth2_resource_owner_id_and_oauth2_client_id(@owner.id,@auth.client.id)
        unless @authenticated_owner
          @oauth2_authorization_instance = Oauth2Authorization.new()
          @instance = @oauth2_authorization_instance.get_token(@auth.owner, @auth.client,
                    :response_type => "token",
                    :scope => params["scope"].present? ? params["scope"] : nil,
                    :duration => params["duration"].present? ? params["duration"] : 3600)   
        else
          @instance = @authenticated_owner
        end
        if @instance.access_token.nil?                
          error_message = Oauth2Authorization.error_response(@oauth2.error_description)
          return error_message, false   
        elsif @instance.code.nil? && request_type == "user"
          error = "Invalid request. Request token generation required."
          error_message = Oauth2Authorization.error_response(error)
          return error_message, false   
        else
          if request_type == "bearer"
            redirect_to_url = @instance.api_response(@auth.redirect_uri)
            return redirect_to_url, true 
          elsif @instance.code == params.request_token && request_type == "user"
            redirect_to_url = @instance.api_response(@auth.redirect_uri) 
            return redirect_to_url, true  
          else 
            error = "Invalid request token."
            error_message = Oauth2Authorization.error_response(error)
            return error_message, false      
          end            
        end  
    else
      error_message = Oauth2Authorization.error_response(@oauth2.error_description) 
      return error_message, false  
    end
  end

  def self.invalidate_token(params,env)
    @owner  = Owner.find_by_username(params.host_name+"_bearer")            
    if @owner.nil?
      error = "No Bearer token issued to this client."
      error_message = Oauth2Authorization.error_response(error)
      return error_message, false 
    else
      @oauth2 = Songkick::OAuth2::Provider.parse(@owner, env)
      if @oauth2.valid? 
        @auth = Songkick::OAuth2::Provider::Authorization.new(@owner, params)                 
        @oauth2_authorization_instance = Oauth2Authorization.new()
        @instance = @oauth2_authorization_instance.get_token(@auth.owner,@auth.client,
                  :response_type => "token",
                  :invalidate => true)                                                  
        return @instance.redirect(@auth), true                   
      else
        error_message = Oauth2Authorization.error_response(@oauth2.error_description) 
        return error_message, false  
      end
    end
  end

  def redirect_to_url(callback_url)
    client_details = "client_id=#{self.client_id}"
    return callback_url + "?#{client_details}"
  end

  protected

  def generate_keys
    self.client_id = OAuth::Helper.generate_key(40)[0,40]
    self.client_secret_hash = OAuth::Helper.generate_key(40)[0,40]
  end
end