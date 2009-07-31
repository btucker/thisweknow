# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def location_path(location)
    url_for(:controller => 'locations', :action => 'show', :city => location.city, :state => location.state)
  end
  helper_method :location_path

  def factoid_path(factoid, location=nil)
    if location
      url_for(:controller => 'locations', :action => 'factoid', :id => factoid.id, :city => location.city, :state => location.state)      
    else
      super(factoid)
    end
  end
  helper_method :factoid_path

protected
 
end
