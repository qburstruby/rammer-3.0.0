class User < ActiveRecord::Base

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

	def self.validate_oauth_params(params,base_api)
		if params.client_id && params.response_type && User.valid_redirect_uri?(params.redirect_uri)
			if params.response_type == "code" && (base_api == "request_token" || base_api == "authorize")
				return true 
			elsif params.response_type == "token" && base_api != "request_token"
				return true
			end
		end
	end

	def self.sign_up(params)
		@user =  User.create!(:email => params.email, :encrypted_password => params.password)
		@session = @user.sign_in(params)
		return @user, @session
	end

	def self.valid_email?(email)
		return true if email =~ RubyRegex::Email 
	end

	def self.valid_password?(password)
		return true if password =~ /^[0-9a-f]{32}$/i
	end

	def self.valid_redirect_uri?(redirect_uri)
		return true if !redirect_uri.empty? && redirect_uri =~ RubyRegex::Url
	end

	def sign_in(params)
		token = Digest::SHA1.hexdigest("#{SecureRandom.base64}" + "#{self.id}")
		@session = Session.create!(:user_id => self.id, :session_token => token)
		self.update_attribute(:sign_in_count, self.sign_in_count+1)
		return @session
	end

	def sign_out(params)
		@session = Session.find_by_session_token_and_user_id(params.session_token,self.id)
		@session.destroy
	end

	def signed_in?(params)
		Session.find_by_user_id_and_session_token(self.id,params.session_token)
	end

	def self.logged_in?(params)		
		Session.find_by_session_token(params.username)
	end

	def redirect_url(params,session)
		redirect_to_url = params.redirect_uri + "?session_token=#{session.session_token}"
	end

end