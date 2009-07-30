# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def location_path(location)
    url_for(:controller => 'locations', :action => 'show', :city => location.city, :state => location.state)
  end
  helper_method :location_path

protected
 
end
