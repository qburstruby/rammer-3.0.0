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

class Owner < ActiveRecord::Base
  has_many :oauth2_authorizations
=begin
Returns oauth details for specified client id.
=end
  def oauth2_authorization_for(client)
    Oauth2Authorization.find_by_oauth2_client_id(client.id)
  end
=begin
Returns oauth details for specified client id and owner id.
=end
  def oauth2_authorization(client,owner)
    Oauth2Authorization.find_by_oauth2_client_id_and_oauth2_resource_owner_id(client.id,owner.id)
  end
=begin
Processes the /token and /invalidate_token endpoint and returns the required doauth details.
=end
  def self.process_bearer_request(params,env,action)
    flag, void_value = Oauth2Client.valid_authorization?(params)
		if flag && void_value == "present"
      case action
      when "bearer_token"
		    expected_response,response_message = Oauth2Client.grant_access(params,env,"bearer")
      when "invalidate"
        expected_response,response_message = Oauth2Client.invalidate_token(params,env)
      end
      return expected_response,response_message
	  elsif void_value == "present"
			error = "Invalid authorization code"
			error_response = Oauth2Authorization.error_response(error) 
      return error_response,false
		else
		  error = "Invalid client id"
			error_response = Oauth2Authorization.error_response(error) 
      return error_response,false
		end
  end
end