=begin
**************************************************************************
* The MIT License (MIT)

* Copyright (c) 2013-2014 QBurst Technologies Inc.

* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.

**************************************************************************
=end

class Oauth2Client < ActiveRecord::Base
  has_many :oauth2_authorizations
  attr_accessible :name, :client_id, :client_secret_hash, :redirect_uri
  validates_presence_of :name, :client_id, :client_secret_hash, :redirect_uri
  validates_uniqueness_of :client_id

  before_validation :generate_keys, :on => :create
=begin
Registers a new oauth client and returns the required details.
=end
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
=begin
Checks for valid authorization basic code.
=end
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
=begin
Processes the /access_token and /request_token endpoint and returns the required doauth details.
=end
  def self.process_request(params,env,action)
    if User.logged_in?(params)
      case action
      when "code"
        expected_response,response_message = Oauth2Client.grant_code(params,env)
      when "token"
        expected_response,response_message = Oauth2Client.grant_access(params,env,"user")
      end
      return expected_response,response_message
    else
      error = "Invalid user session."
      error_response = Oauth2Authorization.error_response(error) 
      return error_response,false
    end
  end
=begin
Creates and returns request token for the client.
=end
  def self.grant_code(params,env)
    @owner  = Owner.find_by_username(params.username)
    @owner = Owner.create(:username => params.username) if @owner.nil?

    @oauth2 = Songkick::OAuth2::Provider.parse(@owner, env)  
    if @oauth2.valid?    
      @auth = Songkick::OAuth2::Provider::Authorization.new(@owner, params)
      @authenticated_owner = Oauth2Authorization.find_by_oauth2_resource_owner_id_and_oauth2_client_id(@owner.id,@auth.client.id)
      unless @authenticated_owner
        @instance = Oauth2Client.obtain_token(params, @auth,"code")
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
=begin
Creates and returns access token for the client.
=end
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
        @instance = Oauth2Client.obtain_token(params, @auth,"token")   
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
=begin
Invalidates the bearer token for the specifies client.
=end
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
=begin
Builds the redirect url for oauth.
=end
  def redirect_to_url(callback_url)
    client_details = "client_id=#{self.client_id}"
    return callback_url + "?#{client_details}"
  end

  protected
=begin
Creates and returns oauth client secret key hash and id.
=end
  def generate_keys
    self.client_id = OAuth::Helper.generate_key(40)[0,40]
    self.client_secret_hash = OAuth::Helper.generate_key(40)[0,40]
  end
=begin
Creates and returns the basic oauth details.
=end
  def self.obtain_token(params, auth,action)
    @oauth2_authorization_instance = Oauth2Authorization.new()
    @instance = @oauth2_authorization_instance.get_token(auth.owner, auth.client,
              :response_type => action,
              :scope => params["scope"].present? ? params["scope"] : nil,
              :duration => params["duration"].present? ? params["duration"] : 3600)
    return @instance
  end
end