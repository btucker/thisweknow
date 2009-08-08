class FactoidResult < ActiveRecord::Base
  belongs_to :city
  belongs_to :factoid
end
