# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

protected
  def distance(lon1, lon2, lat1, lat2) #Finds the distance between two coordinates of lat/lon in miles
  	return Math.sqrt((lon_to_miles(lon1, lon2, @zip_lat))**2+(lat_to_miles(lat1, lat2))**2)
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
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
