class AcquisitionStreamSpecsController < ApplicationController
  # GET /acquisition_stream_specs
  # GET /acquisition_stream_specs.xml
  def index
    @acquisition_stream_specs = AcquisitionStreamSpec.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @acquisition_stream_specs }
    end
  end

  # GET /acquisition_stream_specs/1
  # GET /acquisition_stream_specs/1.xml
  def show
    @acquisition_stream_spec = AcquisitionStreamSpec.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @acquisition_stream_spec }
    end
  end

  # GET /acquisition_stream_specs/new
  # GET /acquisition_stream_specs/new.xml
  def new
    @acquisition_stream_spec = AcquisitionStreamSpec.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @acquisition_stream_spec }
    end
  end

  # GET /acquisition_stream_specs/1/edit
  def edit
    @acquisition_stream_spec = AcquisitionStreamSpec.find(params[:id])
  end

  # POST /acquisition_stream_specs
  # POST /acquisition_stream_specs.xml
  def create
    @acquisition_stream_spec = AcquisitionStreamSpec.new(params[:acquisition_stream_spec])

    respond_to do |format|
      if @acquisition_stream_spec.save
        flash[:notice] = 'AcquisitionStreamSpec was successfully created.'
        format.html { redirect_to(@acquisition_stream_spec) }
        format.xml  { render :xml => @acquisition_stream_spec, :status => :created, :location => @acquisition_stream_spec }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @acquisition_stream_spec.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /acquisition_stream_specs/1
  # PUT /acquisition_stream_specs/1.xml
  def update
    @acquisition_stream_spec = AcquisitionStreamSpec.find(params[:id])

    respond_to do |format|
      if @acquisition_stream_spec.update_attributes(params[:acquisition_stream_spec])
        flash[:notice] = 'AcquisitionStreamSpec was successfully updated.'
        format.html { redirect_to(@acquisition_stream_spec) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @acquisition_stream_spec.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /acquisition_stream_specs/1
  # DELETE /acquisition_stream_specs/1.xml
  def destroy
    @acquisition_stream_spec = AcquisitionStreamSpec.find(params[:id])
    @acquisition_stream_spec.destroy

    respond_to do |format|
      format.html { redirect_to(acquisition_stream_specs_url) }
      format.xml  { head :ok }
    end
  end
end
