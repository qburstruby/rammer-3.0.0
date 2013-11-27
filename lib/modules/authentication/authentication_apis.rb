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

  class AuthenticationApis < Grape::API
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
  	 	__send__ method, '/authentication/sign_up' do
  	 		if User.validate_params?(params,"sign_up")
  	 			@existing_user = User.find_by_email(params.email)
  	 			unless @existing_user  		  				
  	 				@user, @session = User.sign_up(params)
						redirect @user.redirect_url(params,@session)
  	 			else
  	 				error = "User already exists."
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