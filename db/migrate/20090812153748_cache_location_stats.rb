class CacheLocationStats < ActiveRecord::Migration
  def self.up
    add_column :cities, :land_area, :float
    add_column :cities, :water_area, :float
    add_column :cities, :households, :integer
  end

  def self.down
    remove_column :cities, :households
    remove_column :cities, :water_area
    remove_column :cities, :land_area
  end
end
