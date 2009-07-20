class ZipsController < ApplicationController

  def index
  end

  def show
    @zip = Zipcode.new(params[:id])
  end
end
