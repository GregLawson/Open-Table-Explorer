class HuelshowsController < ApplicationController
  # GET /huelshows
  # GET /huelshows.xml
  def index
    @huelshows = Huelshow.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @huelshows }
    end
  end

  # GET /huelshows/1
  # GET /huelshows/1.xml
  def show
    @huelshow = Huelshow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @huelshow }
    end
  end

  # GET /huelshows/new
  # GET /huelshows/new.xml
  def new
    @huelshow = Huelshow.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @huelshow }
    end
  end

  # GET /huelshows/1/edit
  def edit
    @huelshow = Huelshow.find(params[:id])
  end

  # POST /huelshows
  # POST /huelshows.xml
  def create
    @huelshow = Huelshow.new(params[:huelshow])

    respond_to do |format|
      if @huelshow.save
        format.html { redirect_to(@huelshow, :notice => 'Huelshow was successfully created.') }
        format.xml  { render :xml => @huelshow, :status => :created, :location => @huelshow }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @huelshow.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /huelshows/1
  # PUT /huelshows/1.xml
  def update
    @huelshow = Huelshow.find(params[:id])

    respond_to do |format|
      if @huelshow.update_attributes(params[:huelshow])
        format.html { redirect_to(@huelshow, :notice => 'Huelshow was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @huelshow.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /huelshows/1
  # DELETE /huelshows/1.xml
  def destroy
    @huelshow = Huelshow.find(params[:id])
    @huelshow.destroy

    respond_to do |format|
      format.html { redirect_to(huelshows_url) }
      format.xml  { head :ok }
    end
  end
end
