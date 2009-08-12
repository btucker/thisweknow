class RemovePointFactoidCaches < ActiveRecord::Migration
  def self.up
    # because we just changed distances
    FactoidResult.delete_all(['factoid_id IN (select id from factoids where factoid_type = "Point")'])
  end

  def self.down
  end
end
