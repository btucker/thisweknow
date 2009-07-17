class CreateFactoids < ActiveRecord::Migration
  def self.up
    create_table :factoids do |t|
      t.string :sentence
      t.text :count_query
      t.text :query

      t.timestamps
    end
  end

  def self.down
    drop_table :factoids
  end
end
