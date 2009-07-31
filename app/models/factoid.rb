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
    result = sentence % count(location)
    result.gsub!(/<n>([^<]+)<\/n>/, '<span class="quantity">\1</span>')
    result.gsub!(/<e>([^<]+)<\/e>/, "<a class='quality' href='#{path(location)}'>\\1</a>")
    result
    rescue Exception
      ""
  end

  def path(location)
    "/l/#{location.state}/#{location.city}/factoids/#{id}" 
  end 
end
