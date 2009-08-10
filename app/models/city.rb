class City < ActiveRecord::Base
  has_many :zipcodes
  has_many :factoid_results

  acts_as_geocodable :address => {:locality => :name, :region => :admin1_code, :country => :country_code}

  def to_s
    "#{name}, #{state}"
  end

  def state
    admin1_code
  end

  def stats
    town = location.find_town    
    res = Sparql.execute("SELECT ?label ?value FROM <census> FROM <ui> WHERE {
                            ?town rdf:type <tag:govshare.info,2005:rdf/usgovt/Town>;
                                  ?label ?value .
                            <tag:govshare.info,2005:rdf/usgovt/Town> ui:attribute ?label .
                            FILTER(?town=<#{town}>)
                         }", :ruby)
    res.each do |stat|
      stat[:label] = stat[:label].sub(/.*[#\/]([^#\/]+)$/, '\1').underscore.titleize
      stat[:value].sub!(/\s*(\w+)\^(\d+)$/) do
        stat[:label] << " <small>(#{$1}<sup>#{$2}</sup>)</small>" 
        ''
      end
    end
    res.select {|stat| stat[:label] != 'Title'}
  end

  def location # our location, not to be confused with the gaticule one
    @location = Location.new(self) unless @location
    @location
  end

  def geocode
    if geocoding
      geocoding.geocode
    else
      create_geocoding(:geocode => Geocode.create(
        :latitude => latitude,
        :longitude => longitude,
        :locality => name,
        :region => admin1_code,
        :country => 'US',
        :precision => 'city'))
    end
  end

  def to_location
    returning Graticule::Location.new do |location|
      [:locality, :region, :country].each do |attr|
        location.send "#{attr}=", geo_attribute(attr)
      end
    end
  end
end
