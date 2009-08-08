class CreateFactoidResults < ActiveRecord::Migration
  def self.up
    create_table :factoid_results do |t|
      t.integer :city_id
      t.integer :factoid_id
      t.float :count1
      t.float :count2
      t.float :count3
      t.float :count4

      t.timestamps
    end
    add_index :factoid_results, [:city_id, :factoid_id]
    add_index :factoid_results, [:factoid_id, :count1, :count2]
  end

  def self.down
    drop_table :factoid_results
  end
end
