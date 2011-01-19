class AcquisitionInterfacesController < ApplicationController
  # GET /acquisition_interfaces
  # GET /acquisition_interfaces.xml
  def index
    @acquisition_interfaces = AcquisitionInterface.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @acquisition_interfaces }
    end
  end

  # GET /acquisition_interfaces/1
  # GET /acquisition_interfaces/1.xml
  def show
    @acquisition_interface = AcquisitionInterface.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @acquisition_interface }
    end
  end

  # GET /acquisition_interfaces/new
  # GET /acquisition_interfaces/new.xml
  def new
    @acquisition_interface = AcquisitionInterface.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @acquisition_interface }
    end
  end

  # GET /acquisition_interfaces/1/edit
  def edit
    @acquisition_interface = AcquisitionInterface.find(params[:id])
  end

  # POST /acquisition_interfaces
  # POST /acquisition_interfaces.xml
  def create
    @acquisition_interface = AcquisitionInterface.new(params[:acquisition_interface])

    respond_to do |format|
      if @acquisition_interface.save
        flash[:notice] = 'AcquisitionInterface was successfully created.'
        format.html { redirect_to(@acquisition_interface) }
        format.xml  { render :xml => @acquisition_interface, :status => :created, :location => @acquisition_interface }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @acquisition_interface.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /acquisition_interfaces/1
  # PUT /acquisition_interfaces/1.xml
  def update
    @acquisition_interface = AcquisitionInterface.find(params[:id])

    respond_to do |format|
      if @acquisition_interface.update_attributes(params[:acquisition_interface])
        flash[:notice] = 'AcquisitionInterface was successfully updated.'
        format.html { redirect_to(@acquisition_interface) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @acquisition_interface.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /acquisition_interfaces/1
  # DELETE /acquisition_interfaces/1.xml
  def destroy
    @acquisition_interface = AcquisitionInterface.find(params[:id])
    @acquisition_interface.destroy

    respond_to do |format|
      format.html { redirect_to(acquisition_interfaces_url) }
      format.xml  { head :ok }
    end
  end
end
