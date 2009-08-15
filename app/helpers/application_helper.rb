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
    when 'CBSA'  
      out << '(in this <abbr title="Core Based Statistical Area">CBSA</abbr>)'
    when "Town"
  	  out << '(in this town)'
    end
    out << '</span>'
    out
  end

  def render_sentence(factoid, location, opt = {})
    counts = factoid.count(location)
    result = factoid.sentence % counts
    result.gsub!(/<n(,?)>([^<]+)<\/n,?>/) do 
      if opt[:as_text]
        $1 == ',' ? number_with_delimiter($2) : $2
      else
        "<span class='quantity'>#{$1 == ',' ? number_with_delimiter($2) : $2}</span>"
      end
    end
    i = 0
    result.gsub!(/<e(1?)>([^<]+)<\/e1?>/) do 
      i += 1
      if opt[:as_text]
        $1 == '1' ? $2 : pluralize_without_count(counts[i-1], $2.singularize)
      else
        "<a class='quality' href='#{factoid_path(factoid, location)}'>#{$1 == '1' ? $2 : pluralize_without_count(counts[i-1], $2.singularize)}</a>"
      end
    end
    result.gsub(/<nosubtext\/?>/,'')
    rescue Exception
      "Sorry, there is not enough data about this location."
  end

  def pluralize_without_count(count, singular, plural = nil)
    ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
  end

end
