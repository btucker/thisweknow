class EntitiesController < ApplicationController
  def show
    @uri = params[:id]
    @resource = RDFS::Resource.new("http://www.data.gov/tri/#{@uri}")
    @label = @resource.label
  end
end
