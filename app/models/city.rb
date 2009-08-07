class City < ActiveRecord::Base
  has_many :zipcodes
  acts_as_geocodable :address => {:locality => :name, :region => :admin1_code, :country => :country_code}

  def to_s
    "#{name}, #{state}"
  end

  def state
    admin1_code
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
