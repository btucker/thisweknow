class AddTownUri < ActiveRecord::Migration
  def self.up
    add_column :cities, :town_uri, :string
  end

  def self.down
    remove_column :cities, :town_uri
  end
end
