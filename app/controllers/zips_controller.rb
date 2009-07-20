class ZipsController < ApplicationController

  def index
  end

  def show
    @zip = Zipcode.new(params[:id])
    @facility_data = @zip.find_facilities
  end


  protected

end
