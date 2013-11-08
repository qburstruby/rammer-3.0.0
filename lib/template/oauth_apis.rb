require 'oauth2'
require 'songkick/oauth2/provider'
module GrapeGoliath 
   
    class OauthApis < Grape::API
    	Songkick::OAuth2::Provider.realm = 'PocketAPI Oauth Server'
        version 'v1', :using => :path
        format :json
# =begin
# This handles api calls for request token generation with the request parameters:
# {"client_id"=> Client's registered ID,
#  "username" => Authorized user's session id,
#  "redirect_uri" => URL to which the oauth should be redirected,
#  "response_type" => "code" (Keyword to return request token)
#  }
# =end
# 	        [:get, :post].each do |method|
# 	  		  	__send__ method, '/oauth/authorize' do
# 	  		  		if User.validate_params?(params,"authorize")
# 				  		if User.logged_in?(params)
# 				  			@oauth2 = Songkick::OAuth2::Provider.parse(@owner, env) 
# 				  			redirect_to_url = "http://invokevokeangular.qburst.com:4000/grantaccess/#{@oauth2.client.name}/#{@oauth2.client.client_id}/#{params.username}" 
# 				  			redirect redirect_to_url
# 						else
# 							error = "Sign in first."
# 							Oauth2Authorization.error_response(error)	
# 						end
# 					else
# 	  		  			error = "Params missing or invalid."
# 						Oauth2Authorization.error_response(error)
# 					end		
# 			  	end
# 			end
=begin
This handles api calls for access token generation with the request parameters:
{"client_id"=> Client's registered ID,
 "username" => Authorized user's session id,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "token" (Keyword to return access token)
 }
=end
		[:get, :post].each do |method|
  		  	__send__ method, '/oauth/access_token' do
  		  		if User.validate_params?(params,"access_token")
		  			if User.logged_in?(params)
		  				expected_response,response_message = Oauth2Client.grant_access(params,env,"user")
						if response_message then redirect expected_response else expected_response end
					else
						error = "Invalid user session."
						Oauth2Authorization.error_response(error)	
					end
				else
  		  			error = "Params missing or invalid."
					Oauth2Authorization.error_response(error)
				end
		  	end
		 end
=begin
This handles api calls for bearer token generation with the request parameters:
{"client_id"=> Client's registered ID,
 "authorization" => Basic authorization key generated while client registration,
 "host_name" => Thirs party client's name,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "token" (Keyword to return bearer token),
 }
 Optional parameters:
 {"scope" => Indicates the API's the application is requesting,
  "duration" => Lifetime of bearer token	
 }
=end
		[:get, :post].each do |method|
  		  	__send__ method, '/oauth/token' do
  		  		if User.validate_params?(params,"token")
  		  			if Oauth2Client.valid_authorization?(params)
  		  				expected_response,response_message = Oauth2Client.grant_access(params,env,"bearer")
  		  				if response_message then redirect expected_response else expected_response end
					else
						error = "Invalid authorization code"
						Oauth2Authorization.error_response(error)
					end
				else
  		  			error = "Parameters missing or invalid."
					Oauth2Authorization.error_response(error)
				end
  		  	end
  		end
=begin
This handles api calls for access token generation with the request parameters:
{"client_id"=> Client's registered ID,
 "authorization" => Basic authorization key generated while client registration,
 "host_name" => Thirs party client's name,
 "redirect_uri" => URL to which the oauth should be redirected,
 "response_type" => "token" (Keyword for invalidation of bearer token only),
 }
=end
  		[:get, :post].each do |method|
  		  	__send__ method, '/oauth/invalidate_token' do
  		  		if User.validate_params?(params,"token")
	  		  		if Oauth2Client.valid_authorization?(params)
	  		  			expected_response,response_message = Oauth2Client.invalidate_token(params,env)
	  		  			if response_message then redirect expected_response else expected_response end
				    else
						error = "Invalid authorization code"
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