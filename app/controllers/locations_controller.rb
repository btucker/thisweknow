class LocationsController < ApplicationController
  before_filter :find_location
  def index
  end

  def show
    @facility_data = @location.find_facilities
  end

  def factoid

  end

  def search
    @location = Location.new(params[:q])
    redirect_to location_path(@location)
    rescue Graticule::Error
      raise ActiveRecord::RecordNotFound
  end

  protected

  def find_location
    @location = Location.new("#{params[:city]}, #{params[:state]}") if params[:city] and params[:state]
  end

end
