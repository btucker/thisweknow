class AddHideToFactoids < ActiveRecord::Migration
  def self.up
    add_column :factoids, :hide, :boolean
  end

  def self.down
    remove_column :factoids, :hide
  end
end
