class AddFactoidResultIndexes < ActiveRecord::Migration
  def self.up
    add_index :factoid_results, :count1
  end

  def self.down
    remove_index :factoid_results, :column => :count1
  end
end
