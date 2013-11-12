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