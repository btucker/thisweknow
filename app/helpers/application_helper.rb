# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def static_map_url(location)
    "http://maps.google.com/staticmap?center=#{location.lat},#{location.lon}&zoom=13&size=206x233&key=#{GOOGLE_MAPS_API_KEY}&maptype=mobile"
  end


  def render_sentence(factoid, location)
    result = factoid.sentence % factoid.count(location)
    result.gsub!(/<n(,?)>([^<]+)<\/n,?>/) do 
      "<span class='quantity'>#{$1 == ',' ? number_with_delimiter($2) : $2}</span>"
    end
    result.gsub!(/<e>([^<]+)<\/e>/, "<a class='quality' href='#{factoid_path(factoid, location)}'>\\1</a>")
    result
    #factoid.count(location).inspect
 #   rescue Exception
  #    ""
  end

end
