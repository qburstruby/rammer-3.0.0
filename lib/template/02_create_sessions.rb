class CreateSessions < ActiveRecord::Migration
	def change
    	create_table(:sessions) do |t|
    		t.string :user_id
    		t.string :session_token
    	end
    	add_index  :sessions, :session_token, :unique => true
	end
end