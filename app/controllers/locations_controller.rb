class LocationsController < ApplicationController

  def index
  end

  def show
    @location = Location.new("#{params[:city]}, #{params[:state]}")
    @facility_data = @location.find_facilities
  end

  def zip
    @location = Location.new(params[:zip])
    redirect_to location_path(@location)
  end

  protected

end
