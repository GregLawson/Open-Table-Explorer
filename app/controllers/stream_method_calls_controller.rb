class StreamMethodCallsController < ApplicationController
  # GET /stream_method_calls
  # GET /stream_method_calls.xml
  def index
    @stream_method_calls = StreamMethodCall.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_method_calls }
    end
  end

  # GET /stream_method_calls/1
  # GET /stream_method_calls/1.xml
  def show
    @stream_method_call = StreamMethodCall.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_method_call }
    end
  end

  # GET /stream_method_calls/new
  # GET /stream_method_calls/new.xml
  def new
    @stream_method_call = StreamMethodCall.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_method_call }
    end
  end

  # GET /stream_method_calls/1/edit
  def edit
    @stream_method_call = StreamMethodCall.find(params[:id])
  end

  # POST /stream_method_calls
  # POST /stream_method_calls.xml
  def create
    @stream_method_call = StreamMethodCall.new(params[:stream_method_call])

    respond_to do |format|
      if @stream_method_call.save
        format.html { redirect_to(@stream_method_call, :notice => 'Stream method call was successfully created.') }
        format.xml  { render :xml => @stream_method_call, :status => :created, :location => @stream_method_call }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_method_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_method_calls/1
  # PUT /stream_method_calls/1.xml
  def update
    @stream_method_call = StreamMethodCall.find(params[:id])

    respond_to do |format|
      if @stream_method_call.update_attributes(params[:stream_method_call])
        format.html { redirect_to(@stream_method_call, :notice => 'Stream method call was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_method_call.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_method_calls/1
  # DELETE /stream_method_calls/1.xml
  def destroy
    @stream_method_call = StreamMethodCall.find(params[:id])
    @stream_method_call.destroy

    respond_to do |format|
      format.html { redirect_to(stream_method_calls_url) }
      format.xml  { head :ok }
    end
  end
end
