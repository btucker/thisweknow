class FactoidsController < ApplicationController
  # GET /factoids
  # GET /factoids.xml
  def index
    @factoids = Factoid.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @factoids }
    end
    @county_data = convert_county
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
  
  def convert_county
  	doc = Sparql.execute("select ?fips ?county ?state from <data> where {
?fips rdf:type o:County .
?fips rdfs:label ?county .
?fips o:partOfState ?fipstate .
?fipstate o:shortName ?state}")
	county_data = []
	doc.search("result").each do |r| 
		county_data << {
			:county_name => county = "#{r.search('binding[name="county"] literal').first.content} county, #{r.search('binding[name="state"] literal').first.content}",
			:uri => r.search('binding[name="fips"] uri').first.content
		}
	end
	county_location_data = []

	county_data.each do |county|
		begin
			county_location = Location.new(county[:county_name])
			county_location_data << {
				:name => county[:county_name],
				:latitude => county_location.lat,
				:longitude => county_location.lon,
				:uri => county[:uri]
			}
		rescue Graticule::Error
		end
		puts county_location_data.last.inspect
	end
	return county_location_data
  end
  
end
