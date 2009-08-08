class AddSources < ActiveRecord::Migration
  def self.up
    add_column :factoids, :source, :string
  end

  def self.down
    remove_column :factoids, :source
  end
end
