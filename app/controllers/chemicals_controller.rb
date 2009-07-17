class ChemicalsController < ApplicationController
  
  def index
  	@facility_name=params[:facility_name]
  	if @facility_name
  		@chemical_list = find_chemicals(@facility_name)
  	end
  end
  	
end
