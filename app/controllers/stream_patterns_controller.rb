class StreamPatternsController < ApplicationController
  # GET /stream_patterns
  # GET /stream_patterns.xml
  def index
    @stream_patterns = StreamPattern.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_patterns }
    end
  end

  # GET /stream_patterns/1
  # GET /stream_patterns/1.xml
  def show
    @stream_pattern = StreamPattern.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_pattern }
    end
  end

  # GET /stream_patterns/new
  # GET /stream_patterns/new.xml
  def new
    @stream_pattern = StreamPattern.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_pattern }
    end
  end

  # GET /stream_patterns/1/edit
  def edit
    @stream_pattern = StreamPattern.find(params[:id])
  end

  # POST /stream_patterns
  # POST /stream_patterns.xml
  def create
    @stream_pattern = StreamPattern.new(params[:stream_pattern])

    respond_to do |format|
      if @stream_pattern.save
        format.html { redirect_to(@stream_pattern, :notice => 'Stream pattern was successfully created.') }
        format.xml  { render :xml => @stream_pattern, :status => :created, :location => @stream_pattern }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_pattern.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_patterns/1
  # PUT /stream_patterns/1.xml
  def update
    @stream_pattern = StreamPattern.find(params[:id])

    respond_to do |format|
      if @stream_pattern.update_attributes(params[:stream_pattern])
        format.html { redirect_to(@stream_pattern, :notice => 'Stream pattern was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_pattern.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_patterns/1
  # DELETE /stream_patterns/1.xml
  def destroy
    @stream_pattern = StreamPattern.find(params[:id])
    @stream_pattern.destroy

    respond_to do |format|
      format.html { redirect_to(stream_patterns_url) }
      format.xml  { head :ok }
    end
  end
end
