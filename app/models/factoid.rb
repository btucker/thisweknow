class Factoid < ActiveRecord::Base
	
  def execute(zipcode, radius)
    doc = Sparql.execute(query % [zipcode.lat_min(radius).to_f, zipcode.lat_max(radius).to_f, zipcode.lon_min(radius).to_f, zipcode.lon_max(radius).to_f])
    return doc
  end

  def count(zipcode, radius)
  	#Problems: box not circle, can't use binding for count, uses "COPPER COMPOUNDS" instead of input chemical, uses different radius from facilities bit
  	unless @count
      doc = Sparql.execute(count_query % [zipcode.lat_min(radius).to_f, zipcode.lat_max(radius).to_f, zipcode.lon_min(radius).to_f, zipcode.lon_max(radius).to_f])
      @count = doc.search("result literal").map(&:content)
      @count = @count.map {|val| val.to_f.round}
    end
    @count
  end
end
