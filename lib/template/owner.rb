class Owner < ActiveRecord::Base
	has_many :oauth2_authorizations
	def oauth2_authorization_for(client)
        Oauth2Authorization.find_by_oauth2_client_id(client.id)
    end

    def oauth2_authorization(client,owner)
        Oauth2Authorization.find_by_oauth2_client_id_and_oauth2_resource_owner_id(client.id,owner.id)
    end
end