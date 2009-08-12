class City < ActiveRecord::Base
  has_many :zipcodes
  has_many :factoid_results

  METERS_IN_MILE = 1609.344

  acts_as_geocodable :address => {:locality => :name, :region => :admin1_code, :country => :country_code}

  def to_s
    "#{name}, #{state}"
  end

  def state
    admin1_code
  end

  def stats(town=nil)
    unless @stats
      town ||= location.find_town    
      columns = %w(populations households land_area water_area)
      if columns.all?{|c| self[c]}
        res = columns.map {|c| {:label => c.humanize.titleize, :value => self[c]} } 
      else
        res = Sparql.execute("SELECT ?label ?value FROM <census> FROM <ui> WHERE {
                              ?town rdf:type <tag:govshare.info,2005:rdf/usgovt/Town>;
                                    ?label ?value .
                              <tag:govshare.info,2005:rdf/usgovt/Town> ui:attribute ?label .
                              FILTER(?town=<#{town}>)
                           }", :ruby)
      end

      res.each do |stat|
        stat[:label] = stat[:label].sub(/.*[#\/]([^#\/]+)$/, '\1').underscore.titleize
        # update population if we don't already have it (used for nearby)
        column = stat[:label].downcase.gsub(' ','_').to_sym
        stat[:value].sub!(/\s*(\w+)\^(\d+)$/) do
          if $1 == 'm'
            unit = 'mi'
          else
            unit = $1
          end
          stat[:label] << " <small>(#{unit}<sup>#{$2}</sup>)</small>" 
          ''
        end
        stat[:value] = (stat[:value].to_f / (METERS_IN_MILE ** 2) * 10).round / 10.0 if stat[:label] =~ /\(mi<sup>/

        if self.respond_to?(column) and !self.send(column)
          self.update_attribute(column, stat[:value])
          self.geocode if column == :population
        end
        
        stat[:order] =
            case stat[:label]
              when /Population/
                0
              when /Households/
                1
              when /Land/
                2
              when /Water/
                3
              else
                4
            end
        end
      @stats = res.select {|stat| stat[:label] != 'Title'}.sort_by {|s| s[:order]}
    end
    @stats
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
