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
require 'oauth'
require 'ruby_regex'

module Rammer 
   
  class OauthApis < Grape::API
  	Songkick::OAuth2::Provider.realm = 'PocketAPI Oauth Server'
    version 'v1', :using => :path
    format :json

=begin
This handles api calls for oauth requests with the request parameters according to each api called:
For register --> This handles api calls for request token generation with the request parameters:
{"name"=> Client's name,
 "redirect_uri" => URL to which the oauth should be redirected,
 "callback_url" => Url to which the details should be redirected
 }
 For request_token --> This handles api calls for request token generation with the request parameters:
{"client_id"=> Client's registered ID,
 "username" => Authorized user's session id,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "code" (Keyword to return request token)
}
For authorize --> This handles api calls for request token generation with the request parameters:
{"client_id"=> Client's registered ID,
 "username" => Authorized user's session id,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "code" (Keyword to return request token),
 }
For access_token --> This handles api calls for access token generation with the request parameters:
{"client_id"=> Client's registered ID,
 "username" => Authorized user's session id,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "token" (Keyword to return access token),
 "request_token" => "Request token received from /request_token endpoint."
 }
 Optional parameters:
 {"scope" => Indicates the API's the application is requesting,
  "duration" => Lifetime of bearer token  
 }
For token --> This handles api calls for bearer token generation with the request parameters:
{"client_id"=> Client's registered ID,
 "authorization" => Basic authorization key generated while client registration,
 "host_name" => Thirs party client's name,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "token" (Keyword for invalidation of bearer token only),
 }
For invalidate_token --> This handles api calls for invalidating the bearer token generated with the request parameters:
{"client_id"=> Client's registered ID,
 "authorization" => Basic authorization key generated while client registration,
 "host_name" => Thirs party client's name,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "token" (Keyword for invalidation of bearer token only),
 }
=end
    [:get, :post].each do |method|
      __send__ method, '/oauth/:oauth_request' do
        expected_response,response_message = Oauth2Authorization.api_call(params,env,params[:oauth_request])
        if response_message then redirect expected_response else expected_response end    
      end
    end 
  end
end