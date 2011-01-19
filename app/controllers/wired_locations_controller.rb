class WiredLocationsController < ApplicationController
  # GET /wired_locations
  # GET /wired_locations.xml
  def index
    @wired_locations = WiredLocation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wired_locations }
    end
  end

  # GET /wired_locations/1
  # GET /wired_locations/1.xml
  def show
    @wired_location = WiredLocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @wired_location }
    end
  end

  # GET /wired_locations/new
  # GET /wired_locations/new.xml
  def new
    @wired_location = WiredLocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wired_location }
    end
  end

  # GET /wired_locations/1/edit
  def edit
    @wired_location = WiredLocation.find(params[:id])
  end

  # POST /wired_locations
  # POST /wired_locations.xml
  def create
    @wired_location = WiredLocation.new(params[:wired_location])

    respond_to do |format|
      if @wired_location.save
        flash[:notice] = 'WiredLocation was successfully created.'
        format.html { redirect_to(@wired_location) }
        format.xml  { render :xml => @wired_location, :status => :created, :location => @wired_location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wired_location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /wired_locations/1
  # PUT /wired_locations/1.xml
  def update
    @wired_location = WiredLocation.find(params[:id])

    respond_to do |format|
      if @wired_location.update_attributes(params[:wired_location])
        flash[:notice] = 'WiredLocation was successfully updated.'
        format.html { redirect_to(@wired_location) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wired_location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /wired_locations/1
  # DELETE /wired_locations/1.xml
  def destroy
    @wired_location = WiredLocation.find(params[:id])
    @wired_location.destroy

    respond_to do |format|
      format.html { redirect_to(wired_locations_url) }
      format.xml  { head :ok }
    end
  end
end
