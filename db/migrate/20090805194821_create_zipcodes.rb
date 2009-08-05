class CreateZipcodes < ActiveRecord::Migration
  def self.up
    create_table :zipcodes do |t|
      t.string :zipcode
      t.string :city
      t.string :state

      t.timestamps
    end
    add_index :zipcodes, :zipcode
  end

  def self.down
    drop_table :zipcodes
  end
end
