# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def static_map_url(location)
    "http://maps.google.com/staticmap?center=#{location.lat},#{location.lon}&span=#{location.miles_to_lat(location.radius)},#{location.miles_to_lon(location.radius, location.lat)}&size=206x233&key=#{GOOGLE_MAPS_API_KEY}&maptype=mobile"
  end
end
