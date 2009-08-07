class AssociateCitiesToZips < ActiveRecord::Migration
  def self.up
    #add_column :zipcodes, :city_id, :integer
    #add_index :zipcodes, :city_id
    add_index :cities, [:asciiname, :admin1_code]
    add_index :cities, [:name, :admin1_code]
  end

  def self.down
    remove_index :cities, :column => [:name, :admin1_code]
    remove_index :cities, :column => [:asciiname, :admin1_code]
    remove_index :zipcodes, :column => :zipcode
    remove_index :zipcodes, :column => :city_id
    remove_column :zipcodes, :city_id
  end
end
