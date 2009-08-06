class Factoid < ActiveRecord::Base
	
  def execute(location, radius=100)
    if factoid_type == 'Point'
      	radius = 0
      	doc = Sparql.execute(query % [location.lat_min(radius).to_f, location.lat_max(radius).to_f, location.lon_min(radius).to_f, location.lon_max(radius).to_f])
    elsif factoid_type == 'County'
    	county_doc = Sparql.execute("select ?county ?lat ?lon from <data> where{?county rdf:type <http://www.data.gov/ontology#County> . ?county o:location ?loc . ?loc o:latitude ?lat . ?loc o:longitude ?lon . FILTER(?lat > #{location.lat_min(radius).to_f}) . FILTER(?lat < #{location.lat_max(radius).to_f}) . FILTER(?lon > -#{location.lon_min(radius).to_f}) . FILTER(?lon < #{location.lon_max(radius).to_f})}")
		counties = []
    	county_doc.search("result").each do |r|
    		counties << {
        		:county => r.search('binding[name="county"] uri').first.content,
        		:latitude => r.search('binding[name="lat"] literal').first.content.to_f,
        		:longitude => r.search('binding[name="lon"] literal').first.content.to_f
      		}
    	end
    	county_distances = []
    	counties.each do |county|
    		county_distances << {
    			:county => county[:county],
    			:distance => location.distance(county[:longitude], county[:latitude])
    		}
    	end
    	county_distances = county_distances.group_by {|r| r[:distance]}
    	doc = Sparql.execute(query % county)
    end
    return doc
  end

  def count(location, radius=100)
    if factoid_type == 'Point'
      	radius = 0
      	unless @count
		    doc = Sparql.execute(count_query % [location.lat_min(radius).to_f, location.lat_max(radius).to_f, location.lon_min(radius).to_f, location.lon_max(radius).to_f])
		    @count = doc.search("result literal").map(&:content)
		    @count = @count.map {|val| val.to_f.round}
    	end
    elsif factoid_type == 'County'
    	unless @count
		    county = Sparql.execute("select ?county ?lat ?lon from <data> where{?county rdf:type <http://www.data.gov/ontology#County> . ?county o:location ?loc . ?loc o:latitude ?lat . ?loc o:longitude ?lon . FILTER(?lat > #{location.lat_min(radius).to_f}) . FILTER(?lat < #{location.lat_max(radius).to_f}) . FILTER(?lon > #{location.lon_min(radius).to_f}) . FILTER(?lon < #{location.lon_max(radius).to_f})}", :ruby).map do |county|
          county[:distance] = location.distance(county[:lon], county[:lat])
          county
        end.min {|c| c[:distance]}[:county]
	    	
	    	doc = Sparql.execute(count_query % county)
	    	@count = doc.search("result literal").map(&:content)
		    @count = @count.map {|val| val.to_f.round}
    	end
    end
    return @count
  end

  def render_sentence(location)
    result = sentence % count(location)
    result.gsub!(/<n>([^<]+)<\/n>/, '<span class="quantity">\1</span>')
    result.gsub!(/<e>([^<]+)<\/e>/, "<a class='quality' href='#{path(location)}'>\\1</a>")
    result
 #   rescue Exception
  #    ""
  end

  def path(location)
    "/l/#{location.state}/#{location.city}/factoids/#{id}" 
  end 
end
