class StreamMethodsController < ApplicationController
  # GET /stream_methods
  # GET /stream_methods.xml
  def index
    @stream_methods = StreamMethod.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_methods }
    end
  end

  # GET /stream_methods/1
  # GET /stream_methods/1.xml
  def show
    @stream_method = StreamMethod.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_method }
    end
  end

  # GET /stream_methods/new
  # GET /stream_methods/new.xml
  def new
    @stream_method = StreamMethod.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_method }
    end
  end

  # GET /stream_methods/1/edit
  def edit
    @stream_method = StreamMethod.find(params[:id])
  end

  # POST /stream_methods
  # POST /stream_methods.xml
  def create
    @stream_method = StreamMethod.new(params[:stream_method])

    respond_to do |format|
      if @stream_method.save
        format.html { redirect_to(@stream_method, :notice => 'Stream method was successfully created.') }
        format.xml  { render :xml => @stream_method, :status => :created, :location => @stream_method }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_method.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_methods/1
  # PUT /stream_methods/1.xml
  def update
    @stream_method = StreamMethod.find(params[:id])

    respond_to do |format|
      if @stream_method.update_attributes(params[:stream_method])
        format.html { redirect_to(@stream_method, :notice => 'Stream method was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_method.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_methods/1
  # DELETE /stream_methods/1.xml
  def destroy
    @stream_method = StreamMethod.find(params[:id])
    @stream_method.destroy

    respond_to do |format|
      format.html { redirect_to(stream_methods_url) }
      format.xml  { head :ok }
    end
  end
end
