class CreateFactoidDistances < ActiveRecord::Migration
  def self.up
    create_table :factoid_distances do |t|
      t.integer :city_id
      t.integer :factoid_id
      t.float :distance

      t.timestamps
    end
  end

  def self.down
    drop_table :factoid_distances
  end
end
