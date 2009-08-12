class FactoidResult < ActiveRecord::Base
  belongs_to :city
  belongs_to :factoid
  validates_uniqueness_of :city_id, :scope => :factoid_id
end
