class AddAdmin2Index < ActiveRecord::Migration
  def self.up
    add_index :cities, :admin2_code
  end

  def self.down
    remove_index :cities, :column => :admin2_code
  end
end
