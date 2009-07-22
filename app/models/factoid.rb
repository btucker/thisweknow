class Factoid < ActiveRecord::Base
  def execute(zipcode)
    doc = Sparql.execute(query % [zipcode.lat_min.to_f, zipcode.lat_max.to_f, zipcode.lon_min.to_f, zipcode.lon_max.to_f])
    
    @result = []
   # raise doc
    doc.search("result").each {|r| @result << r.search('binding[name="name"] literal').first.content}
    return @result
  end

  def count(zipcode)
  	#Problems: box not circle, can't use binding for count, uses "COPPER COMPOUNDS" instead of input chemical, uses different radius from facilities bit
  	unless @count
    	doc = Sparql.execute(count_query % [zipcode.lat_min.to_f, zipcode.lat_max.to_f, zipcode.lon_min.to_f, zipcode.lon_max.to_f])
    	if @count = doc.search("result literal").first
    		@count = doc.search("result literal").first.content
		end
	end
	return @count
  end
end
