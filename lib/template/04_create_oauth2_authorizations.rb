class CreateOauth2Authorizations < ActiveRecord::Migration
  def self.up
    create_table :oauth2_authorizations do |t|
      t.timestamps
      t.string     :oauth2_resource_owner_type
      t.integer    :oauth2_resource_owner_id
      t.belongs_to :oauth2_client
      t.string     :scope
      t.string     :code,               :limit => 40
      t.string     :access_token,  :limit => 40
      t.string     :refresh_token, :limit => 40
      t.datetime   :expires_at
    end
    add_index :oauth2_authorizations, [:oauth2_client_id, :code]
    add_index :oauth2_authorizations, [:access_token]
    add_index :oauth2_authorizations, [:oauth2_client_id, :access_token], :name => 'access_token_index'
    add_index :oauth2_authorizations, [:oauth2_client_id, :refresh_token], :name => 'refresh_token_index'
  end

  def self.down
    drop_table :oauth2_authorizations
  end
end