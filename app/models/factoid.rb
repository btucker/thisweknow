class Factoid < ActiveRecord::Base
  has_many :factoid_results

  attr_accessor :radius

  def has_data?(location)
    self.count(location).compact.any?
  end

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
	   	town = find_town(location, @radius)
      doc = Sparql.execute(query % town)
    end
    return doc
  end

  def count(location)
  	@radius=100
    if city = location.city_obj and (fr = factoid_results.find(:first, :conditions => {:city_id => city.id}))
      return (1..9).map {|i| fr.send("count#{i}".to_sym)}
    end
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
        
	    	doc = Sparql.execute(count_query % [county, county, county, county])
	    	@count = doc.search("result literal").map(&:content)
		    @count = @count.map {|val| val.to_f.round}
    	end
    elsif factoid_type == 'Town'
    	@radius = 50
    	unless @count
	    	town = find_town(location, @radius)
	    	doc = Sparql.execute(count_query % town)
	    	@count = doc.search("result literal").map(&:content)
		    @count = @count.map {|val| val.to_f.round}
	    end
    end
    if city = location.city_obj and @count.compact.any?
      fr = factoid_results.build(:city_id => city.id)
      @count.each_with_index do |c,i|
        fr.send("count#{i+1}=".to_sym, c)
      end
      fr.save
    end
    return @count + [nil, nil, nil, nil, nil, nil, nil, nil]
  end

  def entity
    sentence =~ /<e>([^<:]+)/
    $1.titleize if $1  
  end

  def find_town(location, radius=nil)
    radius ||= location.radius
    query_start = %Q|
      select ?town ?lat ?lon from <census> where {
        ?town rdf:type <tag:govshare.info,2005:rdf/usgovt/Town>;
        geo:lat ?lat;
        geo:long ?lon;
        ?p ?o .
        FILTER(?lat > #{location.lat_min(radius).to_f}) . 
        FILTER(?lat < #{location.lat_max(radius).to_f}) . 
        FILTER(?lon > #{location.lon_min(radius).to_f}) . 
        FILTER(?lon < #{location.lon_max(radius).to_f}) . 
    |
   	res = Sparql.execute(query_start + "FILTER(contains(?o, '#{location.city.split.first}'))}", :ruby).map do |t|
      t[:distance] = location.distance(t[:lon].to_f, t[:lat].to_f)
      t
		end.min {|a,b| a[:distance] <=> b[:distance]}
    return res[:town] if res

    # fallback to not using name if we can't find it that way
   	res = Sparql.execute(query_start + "}", :ruby).map do |t|
      t[:distance] = location.distance(t[:lon].to_f, t[:lat].to_f)
      t
		end.min {|a,b| a[:distance] <=> b[:distance]}[:town]
  end

end
