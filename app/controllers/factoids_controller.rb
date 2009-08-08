class FactoidsController < ApplicationController
  before_filter :digest_authenticate

  # GET /factoids
  # GET /factoids.xml
  def index
    @factoids = Factoid.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @factoids }
    end
  end

  # GET /factoids/1
  # GET /factoids/1.xml
  def show
    redirect_to factoids_path
  end

  # GET /factoids/new
  # GET /factoids/new.xml
  def new
    @factoid = Factoid.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @factoid }
    end
  end

  # GET /factoids/1/edit
  def edit
    @factoid = Factoid.find(params[:id])
  end

  # POST /factoids
  # POST /factoids.xml
  def create
    @factoid = Factoid.new(params[:factoid])

    respond_to do |format|
      if @factoid.save
        flash[:notice] = 'Factoid was successfully created.'
        format.html { redirect_to factoids_path }
        format.xml  { render :xml => @factoid, :status => :created, :location => @factoid }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @factoid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /factoids/1
  # PUT /factoids/1.xml
  def update
    @factoid = Factoid.find(params[:id])

    respond_to do |format|
      if @factoid.update_attributes(params[:factoid])
        flash[:notice] = 'Factoid was successfully updated.'
        format.html { redirect_to factoids_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @factoid.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def execute
    @factoid = Factoid.find(params[:id])
  end    

  # DELETE /factoids/1
  # DELETE /factoids/1.xml
  def destroy
    @factoid = Factoid.find(params[:id])
    @factoid.destroy

    respond_to do |format|
      format.html { redirect_to(factoids_url) }
      format.xml  { head :ok }
    end
  end


  def digest_authenticate
    authenticate_or_request_with_http_basic("TWK Administration") do |username, pw|
        username == 'twk' && pw == 'thisweknow'
    end
  end

end
