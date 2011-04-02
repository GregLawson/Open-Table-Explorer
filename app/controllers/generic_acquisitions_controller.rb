class GenericAcquisitionsController < ApplicationController
  # GET /generic_acquisitions
  # GET /generic_acquisitions.xml
  def index
    @generic_acquisitions = GenericAcquisition.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @generic_acquisitions }
    end
  end

  # GET /generic_acquisitions/1
  # GET /generic_acquisitions/1.xml
  def show
    @generic_acquisition = GenericAcquisition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @generic_acquisition }
    end
  end

  # GET /generic_acquisitions/new
  # GET /generic_acquisitions/new.xml
  def new
    @generic_acquisition = GenericAcquisition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @generic_acquisition }
    end
  end

  # GET /generic_acquisitions/1/edit
  def edit
    @generic_acquisition = GenericAcquisition.find(params[:id])
  end

  # POST /generic_acquisitions
  # POST /generic_acquisitions.xml
  def create
    @generic_acquisition = GenericAcquisition.new(params[:generic_acquisition])

    respond_to do |format|
      if @generic_acquisition.save
        flash[:notice] = 'GenericAcquisition was successfully created.'
        format.html { redirect_to(@generic_acquisition) }
        format.xml  { render :xml => @generic_acquisition, :status => :created, :location => @generic_acquisition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @generic_acquisition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /generic_acquisitions/1
  # PUT /generic_acquisitions/1.xml
  def update
    @generic_acquisition = GenericAcquisition.find(params[:id])

    respond_to do |format|
      if @generic_acquisition.update_attributes(params[:generic_acquisition])
        flash[:notice] = 'GenericAcquisition was successfully updated.'
        format.html { redirect_to(@generic_acquisition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @generic_acquisition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_acquisitions/1
  # DELETE /generic_acquisitions/1.xml
  def destroy
    @generic_acquisition = GenericAcquisition.find(params[:id])
    @generic_acquisition.destroy

    respond_to do |format|
      format.html { redirect_to(generic_acquisitions_url) }
      format.xml  { head :ok }
    end
  end
end
