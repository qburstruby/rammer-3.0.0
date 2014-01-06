class CreateMigration < ActiveRecord::Migration
  def self.up
    create_table :migration do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :migration
  end
end