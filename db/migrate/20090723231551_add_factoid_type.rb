class AddFactoidType < ActiveRecord::Migration
  def self.up
    add_column :factoids, :factoid_type, :string
  end

  def self.down
    remove_column :factoids, :factoid_type
  end
end
