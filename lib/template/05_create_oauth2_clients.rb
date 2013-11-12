class CreateOauth2Clients < ActiveRecord::Migration
  def self.up
    create_table :oauth2_clients do |t|
      t.string     :name
      t.string     :client_id
      t.string     :client_secret_hash
      t.string     :redirect_uri
      t.string     :basic_code
      t.timestamps
    end
    add_index :oauth2_clients, :client_id, :unique => true
  end

  def self.down
    drop_table :oauth2_clients
  end

end