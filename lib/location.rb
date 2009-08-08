require 'open-uri'

class Location
  attr_reader :location, :lat, :lon, :city, :state, :zip
  attr_accessor :radius

  def initialize(location)
    if location.is_a? City
      @city_obj = city = location
      @zip = (city.zipcodes.first and city.zipcodes.first.zipcode)
      @city = city.name
      @state = city.admin1_code
      @lat = city.latitude.to_f
      @lon = city.longitude.to_f
    elsif location =~ /^\d{5}$/ and 
      (zip = Zipcode.find(:first, 
                          :include => :city,
                          :conditions => ['zipcode = ? AND city_id IS NOT NULL', location]))
      @zip = location
      @city = zip.city_name.humanize
      @state = zip.state
      @lat = zip.city.latitude.to_f
      @lon = zip.city.longitude.to_f
      @city_obj = zip.city
    elsif location =~ /^([^,]+),\s+(\w{2})$/ and
      (city = City.find(:first,
                        :include => :zipcodes,
                        :conditions => {:asciiname => $1, :admin1_code => $2}))
      @city_obj = city
      @zip = (city.zipcodes.first and city.zipcodes.first.zipcode)
      @city = city.name
      @state = city.admin1_code
      @lat = city.latitude.to_f
      @lon = city.longitude.to_f
    else
      @location = ::Geocode.geocoder.locate(location)
      @zip = @location.postal_code
      @city = @location.locality
      @state = @location.region
      @lat = @location.coordinates.first
      @lon = @location.coordinates.second
      @city_obj = City.find(:first,
                            :include => :zipcodes,
                            :conditions => {:name => @location.locality, 
                                            :admin1_code => @location.region})
    end
    @radius = 24 #Put in the database distance HERE
  end

  def population
    if @city_obj
      @city_obj.population
    end
  end

  def cities_nearby
    if @city_obj
      nearest = City.find(:all, :origin => @city_obj.geocode, :within => 300, 
                          :conditions => ['cities.id != ?', @city_obj.id])
      nearest.sort { |a,b| b.population.to_i <=> a.population.to_i }[0..15].sort_by { rand }[0..4].sort_by { |c| c.distance.to_f }
    end
  end

  def senators
    legislators.select do |l|
      l["title"] == "Sen" 
    end
  end

  def reps
    legislators.select do |l|
      l["title"] == 'Rep'
    end
  end

  def legislators
    unless @legislators
      @legislators = 
        ActiveSupport::JSON.decode(
          open("http://services.sunlightlabs.com/api/legislators.allForZip?zip=#{@zip}&apikey=#{SUNLIGHT_API_KEY}").string
        )["response"]["legislators"]
      @legislators.map!{|l| l["legislator"]}
    end
    @legislators
  end

  def to_s
    "#{@city}, #{@state}"
  end

  def lat_min(radius)
  	unless radius == 0
    	lat - miles_to_lat(radius) 
    else
    	lat - miles_to_lat(@radius)
    end
  end

  def lat_max(radius)
  	unless radius == 0
    	lat + miles_to_lat(radius)
    else
    	lat + miles_to_lat(@radius)
    end
  end

  def lon_min(radius)
  	unless radius == 0
    	lon - miles_to_lon(radius, lat)
    else
    	lon - miles_to_lon(@radius, lat)
    end
  end

  def lon_max(radius)
  	unless radius == 0
    	lon + miles_to_lon(radius, lat)
    else
    	lon + miles_to_lon(@radius, lat)
    end
  end

  def find_facilities
	exp = 0 #allows the loop to go through the companies exponentially by distance, this is the exponent
    fac_num = 0
    
    while fac_num < 12 && exp < 13 #Goes through the companies exponentially by distance to find the closest ones
      
		@radius = 1.4142**exp    
  		doc = Sparql.execute("SELECT count(?fac) as ?count ?fac ?loc ?lat ?lon ?name ?cu ?chem ?chemname FROM <data> WHERE { ?fac <http://www.data.gov/ontology#location>  ?loc . ?fac <http://www.w3.org/2000/01/rdf-schema#label> ?name . ?fac <http://www.data.gov/ontology#usesChemical> ?cu . ?cu <http://www.data.gov/ontology#chemical> ?chem . ?chem <http://www.w3.org/2000/01/rdf-schema#label> ?chemname . ?loc <http://www.data.gov/ontology#latitude> ?lat . ?loc <http://www.data.gov/ontology#longitude> ?lon . FILTER(?lat < #{lat_max(self.radius)}) . FILTER(?lat > #{lat_min(self.radius)}) . FILTER(?lon > #{lon_min(self.radius)}) . FILTER(?lon < #{lon_max(self.radius)})}")
  		
	    exp += 1
	    fac_num = 0
	    pot_var = doc.search('binding[name="count"] literal').first
	    if pot_var
	   		fac_num = pot_var.content.to_f
   		end
	end
	all_data = [] #The list of data as received in the query, not organized by company name
	    
	doc.search("result").each do |r|
      all_data << {
        :name => r.search('binding[name="name"] literal').first.content,
        :latitude => r.search('binding[name="lat"] literal').first.content.to_f,
        :longitude => r.search('binding[name="lon"] literal').first.content.to_f,
        :chemical => r.search('binding[name="chemname"] literal').first.content
      }
    end
	    
    all_data = all_data.group_by {|r| r[:name]} #Organizes the data by company name

	useful_data = {}
    all_data.each do |name, information| #Organizes the data better by company name: name -> list of chemicals, longitude, latitude, and distance from zip_mid
      chemical_data = []
      information.each do |info|
      	 chemical_data << {
      	 :name => info[:chemical].titleize,
      	 :url => "http://www.wikipedia.org/wiki/" + info[:chemical].gsub(" ", "_").titleize
  	 	 }
  	  end
      useful_data[name] = {
         :latitude => information.first[:latitude],
         :longitude => information.first[:longitude],
         :chemicals => chemical_data,
         :distance => distance(lon, information.first[:longitude], lat, information.first[:latitude])
      }
      end
      
    unless useful_data.keys.first.nil?
       self.radius = 1.4142**(exp-1)
    end   
    return self.radius
  end  

  def distance(lon, lat) #Finds the distance between two coordinates of lat/lon in miles
  	return Math.sqrt((lon_to_miles(lon, self.lon, self.lat))**2+(lat_to_miles(lat, self.lat))**2)
  end
  
  def lat_to_miles(lat1, lat2) #Converts a difference of latitude to miles
  	return (lat2-lat1)*69.05
  end
  	
  def lon_to_miles(lon1, lon2, current_lat) #Converts a difference of longitude to miles
  	return 69.17*Math.cos(0.01745*current_lat)*(lon2-lon1)
  end
  
  def miles_to_lat(miles) #Converts miles to degrees of latitude
  	return miles/69.05
  end
  
  def miles_to_lon(miles, lat) #Converts miles to degrees of longitude
  	return miles/(69.17*Math.cos(0.01745*lat))
  end

end
