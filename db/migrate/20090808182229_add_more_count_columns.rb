class AddMoreCountColumns < ActiveRecord::Migration
  def self.up
    add_column :factoid_results, :count5, :float
    add_column :factoid_results, :count6, :float
    add_column :factoid_results, :count7, :float
    add_column :factoid_results, :count8, :float
    add_column :factoid_results, :count9, :float
  end

  def self.down
    remove_column :factoid_results, :count9
    remove_column :factoid_results, :count8
    remove_column :factoid_results, :count7
    remove_column :factoid_results, :count6
    remove_column :factoid_results, :count5
  end
end
