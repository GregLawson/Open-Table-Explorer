class StreamPatternArgumentsController < ApplicationController
  # GET /stream_pattern_arguments
  # GET /stream_pattern_arguments.xml
  def index
    @stream_pattern_arguments = StreamPatternArgument.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_pattern_arguments }
    end
  end

  # GET /stream_pattern_arguments/1
  # GET /stream_pattern_arguments/1.xml
  def show
    @stream_pattern_argument = StreamPatternArgument.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_pattern_argument }
    end
  end

  # GET /stream_pattern_arguments/new
  # GET /stream_pattern_arguments/new.xml
  def new
    @stream_pattern_argument = StreamPatternArgument.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_pattern_argument }
    end
  end

  # GET /stream_pattern_arguments/1/edit
  def edit
    @stream_pattern_argument = StreamPatternArgument.find(params[:id])
  end

  # POST /stream_pattern_arguments
  # POST /stream_pattern_arguments.xml
  def create
    @stream_pattern_argument = StreamPatternArgument.new(params[:stream_pattern_argument])

    respond_to do |format|
      if @stream_pattern_argument.save
        format.html { redirect_to(@stream_pattern_argument, :notice => 'Stream pattern argument was successfully created.') }
        format.xml  { render :xml => @stream_pattern_argument, :status => :created, :location => @stream_pattern_argument }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_pattern_argument.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_pattern_arguments/1
  # PUT /stream_pattern_arguments/1.xml
  def update
    @stream_pattern_argument = StreamPatternArgument.find(params[:id])

    respond_to do |format|
      if @stream_pattern_argument.update_attributes(params[:stream_pattern_argument])
        format.html { redirect_to(@stream_pattern_argument, :notice => 'Stream pattern argument was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_pattern_argument.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_pattern_arguments/1
  # DELETE /stream_pattern_arguments/1.xml
  def destroy
    @stream_pattern_argument = StreamPatternArgument.find(params[:id])
    @stream_pattern_argument.destroy

    respond_to do |format|
      format.html { redirect_to(stream_pattern_arguments_url) }
      format.xml  { head :ok }
    end
  end
end
