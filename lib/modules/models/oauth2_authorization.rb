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

class Oauth2Authorization < ActiveRecord::Base
  belongs_to :client, :class_name => 'Oauth2Client'
=begin
Process each oauth api requests for required results.
=end
  def self.api_call(params,env,endpoint)
    if User.validate_params?(params,endpoint)
      case endpoint
      when "register"
        expected_response,response_message = Oauth2Client.register(params)
      when "request_token"
        expected_response,response_message = Oauth2Client.process_request(params,env,"code")
      when "authorize"
        expected_response,response_message = Oauth2Client.process_request(params,env,"authorize")
      when "access_token"
        expected_response,response_message = Oauth2Client.process_request(params,env,"token")
      when "token"
        expected_response,response_message = Owner.process_bearer_request(params,env,"bearer_token")
      when "invalidate_token"
        expected_response,response_message = Owner.process_bearer_request(params,env,"invalidate")
      end
      return expected_response,response_message
    else
      error = "Parameters missing or invalid."
      error_response = Oauth2Authorization.error_response(error) 
      return error_response,false
    end 
  end 
=begin
Creates and returns the basic oauth details.
=end
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
=begin
Creates and returns the basic api response.
=end
  def api_response(redirect_uri)
    redirect_to_url = self.build_url(redirect_uri,"token") 
    self.refresh_access_token if self.expired? 
    return redirect_to_url
  end
=begin
Refreshes the expired access token.
=end
  def refresh_access_token
    self.expires_at = Time.now + 3600   
    save
  end
=begin
Creates and returns the request token code.
=end
  def create_code(client)
    Songkick::OAuth2.generate_id do |code|
        return code
    end
  end
=begin
Creates and returns the access token.
=end
  def create_access_token
    hash = nil
    Songkick::OAuth2.generate_id do |token|
      hash = Songkick::OAuth2.hashify(token)         
    end
    return hash
  end
=begin
Creates and returns the request token hash.
=end
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
=begin
Handles the scope attribute.
=end
  def scopes
    scopes = scope ? scope.split(/\s+/) : []
    scopes = attributes[:scope]
    Set.new(scopes).to_s
  end
=begin
Checks the presence of scope attribute value.
=end
  def in_scope?(request_scope)
    [*request_scope].all?(&scopes.method(:include?))
  end
=begin
Checks the expiry of access token.
=end
  def expired?
    return false unless expires_at
    expires_at < Time.now
  end
=begin
Creates and returns the access token hash.
=end
  def generate_access_token
    self.access_token ||= self.create_access_token
    save && access_token
  end
=begin
Creates and generates the request token code.
=end
  def generate_code
    self.code ||= self.create_code(client)
    save && code
  end
=begin
Creates and returns the error response.
=end
  def self.error_response(error)
    error_response = {
      :error => "Unauthorized access",
      :description => error,
      :status => 401
    }
  end
=begin
Creates and returns the redirect url.
=end
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
=begin
Creates and returns the redirect url basic path.
=end
  def redirect(auth)
    return auth.redirect_uri.split('#',2).first
  end
end