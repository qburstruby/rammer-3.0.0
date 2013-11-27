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

require 'oauth2'
require 'songkick/oauth2/provider'
require 'ruby_regex'

module Rammer
    
  class AuthorizationApis < Grape::API
  	Songkick::OAuth2::Provider.realm = 'PocketAPI Oauth Server'
    version 'v1', :using => :path
    format :json
    
=begin
This web service enables pockit server user sign up process with request parameters:
{"email"=> User email,
"password" => MD5 hash encrypted password,
"redirect_uri" => Callback url for this api call.	
}	
=end
    [:get, :post].each do |method|
  	  __send__ method, '/authorization/sign_in' do
  	  	if User.validate_params?(params,"sign_in")
	      @authroized_user = User.find_by_email_and_encrypted_password(params.email,params.password)
		  if @authroized_user
			@session = @authroized_user.sign_in(params)						
			redirect @authroized_user.redirect_url(params,@session)
		  else
			error = "Not a registered user."
			Oauth2Authorization.error_response(error)
		  end
		else
  		  error = "Parameters missing or invalid."
		  Oauth2Authorization.error_response(error)
		end
	  end
	end

=begin
This web service enables pockit server user sign up process with request parameters:
{"email"=> User email,
"session_token" => Session token obtained during sign in,
"redirect_uri" => Callback url for this api call.	
}	
=end
	[:get, :post].each do |method|
  	  __send__ method, '/authorization/sign_out' do
  		if User.validate_params?(params,"sign_out")
	      @authroized_user = User.find_by_email(params.email)
		  if @authroized_user &&  @authroized_user.signed_in?(params)
			@authroized_user.sign_out(params)
			redirect params.redirect_uri
		  else
			error = "Invalid user or already signed out."
			Oauth2Authorization.error_response(error)
		  end
		else
  		  error = "Parameters missing or invalid."
		  Oauth2Authorization.error_response(error)
		end
	  end
	end
  end
end