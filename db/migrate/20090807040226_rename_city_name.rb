class RenameCityName < ActiveRecord::Migration
  def self.up
    rename_column :zipcodes, :city, :city_name
  end

  def self.down
    rename_column :zipcodes, :city_name, :city
  end
end
