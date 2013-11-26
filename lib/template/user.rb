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

class User < ActiveRecord::Base
=begin
Validation method for all params.
=end
  def self.validate_params?(params,base_api)
		case(base_api)
		when "register"
			if params.name && params.redirect_uri && params.callback_url && !params.callback_url.empty?
				return true if User.valid_redirect_uri?(params.redirect_uri) 
			end
		when "sign_up", "sign_in"
			if params.email && params.password && params.redirect_uri
				return true if User.valid_email?(params.email) && User.valid_password?(params.password) && User.valid_redirect_uri?(params.redirect_uri)
			end
		when "sign_out"
			if params.email && params.session_token  && params.redirect_uri
				return true if User.valid_email?(params.email) && User.valid_redirect_uri?(params.redirect_uri)
			end
		when "access_token" 
			if params.username && params.redirect_uri && params.request_token
				return true if User.validate_oauth_params(params,base_api) 
			end
		when "authorize", "request_token"
			if params.username && params.redirect_uri
				return true if User.validate_oauth_params(params,base_api) 
			end
		when "token", "invalidate_token"
			if params.host_name && params.authorization && params.redirect_uri
				return true if User.validate_oauth_params(params,base_api) 
			end
		else
			return false
		end
	end
=begin
Validation method for oauth params.
=end
	def self.validate_oauth_params(params,base_api)
		if params.client_id && params.response_type && User.valid_redirect_uri?(params.redirect_uri)
			if params.response_type == "code" && (base_api == "request_token" || base_api == "authorize")
				return true 
			elsif params.response_type == "token" && base_api != "request_token"
				return true
			end
		end
	end
=begin
Creates a user and returns session id.
=end
	def self.sign_up(params)
		@user =  User.create!(:email => params.email, :encrypted_password => params.password)
		@session = @user.sign_in(params)
		return @user, @session
	end
=begin
Validation method for email params.
=end
	def self.valid_email?(email)
		return true if email =~ RubyRegex::Email 
	end
=begin
Validation method for password params.
=end
	def self.valid_password?(password)
		return true if password =~ /^[0-9a-f]{32}$/i
	end
=begin
Validation method for redirect uri params.
=end
	def self.valid_redirect_uri?(redirect_uri)
		return true if !redirect_uri.empty? && redirect_uri =~ RubyRegex::Url
	end
=begin
Enables a user log in and returns session id.
=end
	def sign_in(params)
		token = Digest::SHA1.hexdigest("#{SecureRandom.base64}" + "#{self.id}")
		@session = Session.create!(:user_id => self.id, :session_token => token)
		self.update_attribute(:sign_in_count, self.sign_in_count+1)
		return @session
	end
=begin
Enables user sign out.
=end
	def sign_out(params)
		@session = Session.find_by_session_token_and_user_id(params.session_token,self.id)
		@session.destroy
	end
=begin
Checks for user sign in.
=end
	def signed_in?(params)
		Session.find_by_user_id_and_session_token(self.id,params.session_token)
	end
=begin
Checks or user sign in using session id for oauth endpoints.
=end
	def self.logged_in?(params)		
		Session.find_by_session_token(params.username)
	end
=begin
Builds the redirect uri for returning session token.
=end
	def redirect_url(params,session)
		redirect_to_url = params.redirect_uri + "?session_token=#{session.session_token}"
	end

end