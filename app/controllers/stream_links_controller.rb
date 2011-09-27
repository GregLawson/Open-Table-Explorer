class StreamLinksController < ApplicationController
  # GET /stream_links
  # GET /stream_links.xml
  def index
    @stream_links = StreamLink.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_links }
    end
  end

  # GET /stream_links/1
  # GET /stream_links/1.xml
  def show
    @stream_link = StreamLink.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_link }
    end
  end

  # GET /stream_links/new
  # GET /stream_links/new.xml
  def new
    @stream_link = StreamLink.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_link }
    end
  end

  # GET /stream_links/1/edit
  def edit
    @stream_link = StreamLink.find(params[:id])
  end

  # POST /stream_links
  # POST /stream_links.xml
  def create
    @stream_link = StreamLink.new(params[:stream_link])

    respond_to do |format|
      if @stream_link.save
        format.html { redirect_to(@stream_link, :notice => 'Stream link was successfully created.') }
        format.xml  { render :xml => @stream_link, :status => :created, :location => @stream_link }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_links/1
  # PUT /stream_links/1.xml
  def update
    @stream_link = StreamLink.find(params[:id])

    respond_to do |format|
      if @stream_link.update_attributes(params[:stream_link])
        format.html { redirect_to(@stream_link, :notice => 'Stream link was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_links/1
  # DELETE /stream_links/1.xml
  def destroy
    @stream_link = StreamLink.find(params[:id])
    @stream_link.destroy

    respond_to do |format|
      format.html { redirect_to(stream_links_url) }
      format.xml  { head :ok }
    end
  end
end
