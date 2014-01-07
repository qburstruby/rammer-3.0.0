module AppName
	module ScaffoldName
  	class BaseApis < Grape::API
  		format :json

=begin
Handles read functionality
=end
  		get '/model' do
  			Model.read
  		end

=begin
Handles new record creation
=end
  		post '/model' do
  			Model.create(params)
  		end

=begin
Handles a record updation with respect to record id passed
=end
  		post '/model/:id' do
  			Model.edit(params)
  		end

=begin
Handles a record deletion with respect to record id passed
=end
  		delete '/model/:id' do
  			Model.destroy(params)
  		end
  	end
  end
end