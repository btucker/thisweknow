require 'open-uri'

class Zipcode
  attr_reader :geocoder, :location, :lat, :lon

  def initialize(zip)
    if zip =~ /^\d{5}$/
      @zip = zip
      @geocoder = Graticule.service(:google).new GOOGLE_MAPS_API_KEY
      @location = @geocoder.locate(@zip)
      @lat = @location.coordinates.first
      @lon = @location.coordinates.second
    else
      raise ActiveRecord::RecordNotFound
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
    @zip
  end

  def find_facilities
    lat_min = lat - miles_to_lat(64) #These variables tell the query to find all the companies in a 64 by 64 mi box, centered at the middle of the zip entered
    lat_max = lat + miles_to_lat(64)
    lon_min = lon - miles_to_lon(64, lat)
    lon_max = lon + miles_to_lon(64, lat)
    
      doc = Sparql.execute("SELECT ?fac ?loc ?lat ?lon ?name ?cu ?chem ?chemname FROM <data> WHERE { ?fac <http://www.data.gov/ontology#location>  ?loc . ?fac <http://www.w3.org/2000/01/rdf-schema#label> ?name . ?fac <http://www.data.gov/ontology#usesChemical> ?cu . ?cu <http://www.data.gov/ontology#chemical> ?chem . ?chem <http://www.w3.org/2000/01/rdf-schema#label> ?chemname . ?loc <http://www.data.gov/ontology#latitude> ?lat . ?loc <http://www.data.gov/ontology#longitude> ?lon . FILTER(?lat < #{lat_max}) . FILTER(?lat > #{lat_min}) . FILTER(?lon > #{lon_min}) . FILTER(?lon < #{lon_max})}")
      
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
      useful_data[name] = {
         :latitude => information.first[:latitude],
         :longitude => information.first[:longitude],
         :chemicals => information.map{|info| info[:chemical].titleize},
         :distance => distance(lon, information.first[:longitude], lat, information.first[:latitude])
      }
      end
      
      exp = 0 #allows the loop to go through the companies exponentially by distance, this is the exponent
      return_data = {}
    
      while return_data.keys.size < 12 && exp < 12 #Goes through the companies exponentially by distance to find the closest ones
      useful_data.each do |name, information|
        if information[:distance] < 1.4142**exp
          return_data[name] = useful_data[name]
        end
      end
      exp += 1
      end
      unless return_data.keys.first.nil?
         return_data[return_data.keys.first][:radius] = 1.4142**(exp-1)
      end   
    #return_data.sort_by {|data| data[:distance]}
    return return_data
  end  

  def distance(lon1, lon2, lat1, lat2) #Finds the distance between two coordinates of lat/lon in miles
  	return Math.sqrt((lon_to_miles(lon1, lon2, self.lat))**2+(lat_to_miles(lat1, lat2))**2)
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
