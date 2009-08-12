class Factoid < ActiveRecord::Base
  has_many :factoid_results

  attr_accessor :radius

  def has_data?(location)
    self.count(location).compact.any?
  end

  def execute_query(location)
  	@radius=location.radius
    @formatted_query ||= {}
    unless @formatted_query[location.city_obj.id]
      if factoid_type == 'Point'
        @formatted_query[location.city_obj.id] = query % [location.lat_min(@radius).to_f, 
                                                          location.lat_max(@radius).to_f, 
                                                          location.lon_min(@radius).to_f, 
                                                          location.lon_max(@radius).to_f]

      elsif factoid_type == 'County' || factoid_type == 'CBSA'
        county = Sparql.execute("select ?county ?lat ?lon from <data> where{?county rdf:type <http://www.data.gov/ontology#County> . ?county o:location ?loc . ?loc o:latitude ?lat . ?loc o:longitude ?lon . FILTER(?lat > #{location.lat_min(@radius).to_f}) . FILTER(?lat < #{location.lat_max(@radius).to_f}) . FILTER(?lon > #{location.lon_min(@radius).to_f}) . FILTER(?lon < #{location.lon_max(@radius).to_f})}", :ruby).map do |c|
            c[:distance] = location.distance(c[:lon].to_f, c[:lat].to_f)
            c
        end.min {|a,b| a[:distance] <=> b[:distance]}[:county]
        @formatted_query[location.city_obj.id] = query % county

      elsif factoid_type == 'Town'
        @radius = 50
        town = location.find_town(@radius)
        @formatted_query[location.city_obj.id] = query % town

      end
    end
    @formatted_query[location.city_obj.id]
  end

  def execute(location)
    Sparql.execute(execute_query(location))
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
    elsif factoid_type == 'County' || factoid_type == 'CBSA'
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
	    	town = location.find_town(@radius)
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

end
