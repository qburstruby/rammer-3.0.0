class CreateOwner < ActiveRecord::Migration
	def self.up
	    create_table :owners do |t|
	      t.timestamps
	      t.string     :username
	     end
		add_index :owners, [:username]
 	end

 	def self.down
	    drop_table :owners
  	end
end