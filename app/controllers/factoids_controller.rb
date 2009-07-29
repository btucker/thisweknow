class FactoidsController < ApplicationController
  before_filter :find_zipcode
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
    @factoid = Factoid.find(params[:id])
    
	if @factoid.factoid_type == "Point"
    	@result = @factoid.execute(@zip, 0)
    else
    	@result = @factoid.execute(@zip, 250)
    end
    
    variables = []
    @result.search("head variable").map{|var| var["name"]}.each_slice(2) do |slice|
    	variables << slice
	end
    @headings = variables.map{|v|v[0]}
    
    
    @data = [] #The list of data as received in the query, not organized by company name
	#render :xml => @result
	#return    
	@result.search("result").each do |r|
      row = {}
      	variables.each do |lit_var, uri_var|
	        row[lit_var.to_sym] = [
	        						r.search("binding[name=#{lit_var}] literal").first.content, 
	        						r.search("binding[name=#{uri_var}] uri").first.content
        						]
	    end
	    @data << row
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @factoid }
    end
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
        format.html { redirect_to(@factoid) }
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
        format.html { redirect_to(@factoid) }
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
  
protected
  
  def find_zipcode
  	@zip = Zipcode.new("05301")
  end
end
