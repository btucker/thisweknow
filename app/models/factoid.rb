class Factoid < ActiveRecord::Base
	
  def execute(location)
  	@radius=100
    if factoid_type == 'Point'
      	@radius = 0
      	doc = Sparql.execute(query % [location.lat_min(@radius).to_f, location.lat_max(@radius).to_f, location.lon_min(@radius).to_f, location.lon_max(@radius).to_f])
    elsif factoid_type == 'County'
    	county = Sparql.execute("select ?county ?lat ?lon from <data> where{?county rdf:type <http://www.data.gov/ontology#County> . ?county o:location ?loc . ?loc o:latitude ?lat . ?loc o:longitude ?lon . FILTER(?lat > #{location.lat_min(@radius).to_f}) . FILTER(?lat < #{location.lat_max(@radius).to_f}) . FILTER(?lon > #{location.lon_min(@radius).to_f}) . FILTER(?lon < #{location.lon_max(@radius).to_f})}", :ruby).map do |c|
          c[:distance] = location.distance(c[:lon].to_f, c[:lat].to_f)
          c
		end.min {|a,b| a[:distance] <=> b[:distance]}[:county]
    	doc = Sparql.execute(query % county)
    elsif factoid_type == 'Town'
    	@radius = 50
    	town = Sparql.execute("select ?town ?lat ?lon from <data> where{?town rdf:type <tag:govshare.info,2005:rdf/usgovt/Town> . ?town <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat . ?town <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?lon . FILTER(?lat > #{location.lat_min(@radius).to_f}) . FILTER(?lat < #{location.lat_max(@radius).to_f}) . FILTER(?lon > #{location.lon_min(@radius).to_f}) . FILTER(?lon < #{location.lon_max(@radius).to_f})}", :ruby).map do |t|
          t[:distance] = location.distance(c[:lon].to_f, c[:lat].to_f)
          t
		end.min {|a,b| a[:distance] <=> b[:distance]}[:town]
    	doc = Sparql.execute(query % town)
    end
    return doc
  end

  def count(location)
  	@radius=100
    if factoid_type == 'Point'
      	@radius = 0
      	unless @count
		    doc = Sparql.execute(count_query % [location.lat_min(@radius).to_f, location.lat_max(@radius).to_f, location.lon_min(@radius).to_f, location.lon_max(@radius).to_f])
		    @count = doc.search("result literal").map(&:content)
		    @count = @count.map {|val| val.to_f.round}
    	end
    elsif factoid_type == 'County'
    	unless @count
		    county = Sparql.execute("select ?county ?lat ?lon from <data> where{?county rdf:type <http://www.data.gov/ontology#County> . ?county o:location ?loc . ?loc o:latitude ?lat . ?loc o:longitude ?lon . FILTER(?lat > #{location.lat_min(@radius).to_f}) . FILTER(?lat < #{location.lat_max(@radius).to_f}) . FILTER(?lon > #{location.lon_min(@radius).to_f}) . FILTER(?lon < #{location.lon_max(@radius).to_f})}", :ruby).map do |c|
          c[:distance] = location.distance(c[:lon].to_f, c[:lat].to_f)
          c
		end.min {|a,b| a[:distance] <=> b[:distance]}[:county]
        
	    	doc = Sparql.execute(count_query % county)
	    	@count = doc.search("result literal").map(&:content)
		    @count = @count.map {|val| val.to_f.round}
    	end
    elsif factoid_type == 'Town'
    	@radius = 50
    	unless @count
	    	town = Sparql.execute("select ?town ?lat ?lon from <data> where{?town rdf:type <tag:govshare.info,2005:rdf/usgovt/Town> . ?town <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat . ?town <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?lon . FILTER(?lat > #{location.lat_min(@radius).to_f}) . FILTER(?lat < #{location.lat_max(@radius).to_f}) . FILTER(?lon > #{location.lon_min(@radius).to_f}) . FILTER(?lon < #{location.lon_max(@radius).to_f})}", :ruby).map do |t|
	          t[:distance] = location.distance(c[:lon].to_f, c[:lat].to_f)
	          t
			end.min {|a,b| a[:distance] <=> b[:distance]}[:town]
	    	doc = Sparql.execute(count_query % town)
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

  def entity
    sentence =~ /<e>([^<]+)<\/e>/
    $1.humanize
  end

end
