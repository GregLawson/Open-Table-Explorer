class StreamMethodArgumentsController < ApplicationController
  # GET /stream_method_arguments
  # GET /stream_method_arguments.xml
  def index
    @stream_method_arguments = StreamMethodArgument.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_method_arguments }
    end
  end

  # GET /stream_method_arguments/1
  # GET /stream_method_arguments/1.xml
  def show
    @stream_method_argument = StreamMethodArgument.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_method_argument }
    end
  end

  # GET /stream_method_arguments/new
  # GET /stream_method_arguments/new.xml
  def new
    @stream_method_argument = StreamMethodArgument.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_method_argument }
    end
  end

  # GET /stream_method_arguments/1/edit
  def edit
    @stream_method_argument = StreamMethodArgument.find(params[:id])
  end

  # POST /stream_method_arguments
  # POST /stream_method_arguments.xml
  def create
    @stream_method_argument = StreamMethodArgument.new(params[:stream_method_argument])

    respond_to do |format|
      if @stream_method_argument.save
        format.html { redirect_to(@stream_method_argument, :notice => 'Stream method argument was successfully created.') }
        format.xml  { render :xml => @stream_method_argument, :status => :created, :location => @stream_method_argument }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_method_argument.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_method_arguments/1
  # PUT /stream_method_arguments/1.xml
  def update
    @stream_method_argument = StreamMethodArgument.find(params[:id])

    respond_to do |format|
      if @stream_method_argument.update_attributes(params[:stream_method_argument])
        format.html { redirect_to(@stream_method_argument, :notice => 'Stream method argument was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_method_argument.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_method_arguments/1
  # DELETE /stream_method_arguments/1.xml
  def destroy
    @stream_method_argument = StreamMethodArgument.find(params[:id])
    @stream_method_argument.destroy

    respond_to do |format|
      format.html { redirect_to(stream_method_arguments_url) }
      format.xml  { head :ok }
    end
  end
end
