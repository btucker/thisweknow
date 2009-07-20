class Factoid < ActiveRecord::Base
  def execute(zipcode)
    @result ||= Sparql.execute(query % [zipcode.lat_min, zipcode.lat_max, zipcode.lon_min, zipcode.lon_max])
  end

  def count(zipcode)
    @count ||= Sparql.execute(count_query % [zipcode.lat_min, zipcode.lat_max, zipcode.lon_min, zipcode.lon_max])
  end
end
