# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def static_map_url(location)
    "http://maps.google.com/staticmap?center=#{location.lat},#{location.lon}&span=#{location.miles_to_lat(location.radius)},#{location.miles_to_lon(location.radius, location.lat)}&size=206x233&key=#{GOOGLE_MAPS_API_KEY}&maptype=mobile"
  end

  def subtext(factoid, location)
    out = '<span class="subtext">'
    case factoid.factoid_type
    when 'Point' 
	    out << "(within #{location.radius} mi.)"
    when "County"
  	  out << '(in this county)'
    when "Town"
  	  out << '(in this town)'
    end
    out << '</span>'
    out
  end

  def render_sentence(factoid, location)
    result = factoid.sentence % factoid.count(location) 
    result.gsub!(/<n(,?)>([^<]+)<\/n,?>/) do 
      "<span class='quantity'>#{$1 == ',' ? number_with_delimiter($2) : $2}</span>"
    end
    result.gsub!(/<e>([^<]+)<\/e>/, "<a class='quality' href='#{factoid_path(factoid, location)}'>\\1</a>")
    result
    rescue Exception
      "Sorry, there is not enough data about this location."
  end

end
