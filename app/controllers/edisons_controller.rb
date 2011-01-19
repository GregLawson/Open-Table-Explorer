class EdisonsController < ApplicationController
  # GET /edisons
  # GET /edisons.xml
  def index
    @edisons = Edison.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @edisons }
    end
  end

  # GET /edisons/1
  # GET /edisons/1.xml
  def show
    @edison = Edison.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @edison }
    end
  end

  # GET /edisons/new
  # GET /edisons/new.xml
  def new
    @edison = Edison.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @edison }
    end
  end

  # GET /edisons/1/edit
  def edit
    @edison = Edison.find(params[:id])
  end

  # POST /edisons
  # POST /edisons.xml
  def create
    @edison = Edison.new(params[:edison])

    respond_to do |format|
      if @edison.save
        flash[:notice] = 'Edison was successfully created.'
        format.html { redirect_to(@edison) }
        format.xml  { render :xml => @edison, :status => :created, :location => @edison }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @edison.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /edisons/1
  # PUT /edisons/1.xml
  def update
    @edison = Edison.find(params[:id])

    respond_to do |format|
      if @edison.update_attributes(params[:edison])
        flash[:notice] = 'Edison was successfully updated.'
        format.html { redirect_to(@edison) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edison.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /edisons/1
  # DELETE /edisons/1.xml
  def destroy
    @edison = Edison.find(params[:id])
    @edison.destroy

    respond_to do |format|
      format.html { redirect_to(edisons_url) }
      format.xml  { head :ok }
    end
  end
end
