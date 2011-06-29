class StreamParametersController < ApplicationController
  # GET /stream_parameters
  # GET /stream_parameters.xml
  def index
    @stream_parameters = StreamParameter.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_parameters }
    end
  end

  # GET /stream_parameters/1
  # GET /stream_parameters/1.xml
  def show
    @stream_parameter = StreamParameter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_parameter }
    end
  end

  # GET /stream_parameters/new
  # GET /stream_parameters/new.xml
  def new
    @stream_parameter = StreamParameter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_parameter }
    end
  end

  # GET /stream_parameters/1/edit
  def edit
    @stream_parameter = StreamParameter.find(params[:id])
  end

  # POST /stream_parameters
  # POST /stream_parameters.xml
  def create
    @stream_parameter = StreamParameter.new(params[:stream_parameter])

    respond_to do |format|
      if @stream_parameter.save
        format.html { redirect_to(@stream_parameter, :notice => 'Stream parameter was successfully created.') }
        format.xml  { render :xml => @stream_parameter, :status => :created, :location => @stream_parameter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_parameter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_parameters/1
  # PUT /stream_parameters/1.xml
  def update
    @stream_parameter = StreamParameter.find(params[:id])

    respond_to do |format|
      if @stream_parameter.update_attributes(params[:stream_parameter])
        format.html { redirect_to(@stream_parameter, :notice => 'Stream parameter was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_parameter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_parameters/1
  # DELETE /stream_parameters/1.xml
  def destroy
    @stream_parameter = StreamParameter.find(params[:id])
    @stream_parameter.destroy

    respond_to do |format|
      format.html { redirect_to(stream_parameters_url) }
      format.xml  { head :ok }
    end
  end
end
