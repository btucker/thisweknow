# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def location_path(location)
    url_for(:controller => 'locations', :action => 'show', :city => location.city.gsub(' ','_'), :state => location.state)
  end
  helper_method :location_path

  def list_path(list_name)
    url_for(:controller => 'list', :action => 'show', :id => list_name.gsub(' ', '_'))
  end
  helper_method :list_path

  def factoid_path(factoid, location=nil)
    if location
      url_for(:controller => 'locations', :action => 'factoid', :id => factoid.id, :city => location.city, :state => location.state)      
    else
      super(factoid)
    end
  end
  helper_method :factoid_path

protected
 
  def digest_authenticate
    authenticate_or_request_with_http_basic("TWK Administration") do |username, pw|
        username == APP_CONFIG['admin']['username'] && pw == APP_CONFIG['admin']['password']
    end
  end

  def with_delimiter(number)
    delimiter = ','
    separator = '.'
    begin
      parts = number.to_s.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
      parts.join(separator)
    rescue
      number
    end
  end
end
