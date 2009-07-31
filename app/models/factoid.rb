class Factoid < ActiveRecord::Base
	
  def execute(location, radius=250)
    if factoid_type == 'Point'
      radius = 0
    end
    doc = Sparql.execute(query % [location.lat_min(radius).to_f, location.lat_max(radius).to_f, location.lon_min(radius).to_f, location.lon_max(radius).to_f])
    return doc
  end

  def count(location, radius=250)
    if factoid_type == 'Point'
      radius = 0
    end
  	unless @count
      doc = Sparql.execute(count_query % [location.lat_min(radius).to_f, location.lat_max(radius).to_f, location.lon_min(radius).to_f, location.lon_max(radius).to_f])
      @count = doc.search("result literal").map(&:content)
      @count = @count.map {|val| val.to_f.round}
    end
    @count
  end

  def render_sentence(location)
    sentence % count(location)
    rescue Exception
      ""
  end
end
