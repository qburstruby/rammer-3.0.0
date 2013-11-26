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