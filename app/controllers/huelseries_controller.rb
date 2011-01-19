class HuelseriesController < ApplicationController
  # GET /huelseries
  # GET /huelseries.xml
  def index
    @huelseries = Huelserie.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @huelseries }
    end
  end

  # GET /huelseries/1
  # GET /huelseries/1.xml
  def show
    @huelseries = Huelserie.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @huelseries }
    end
  end

  # GET /huelseries/new
  # GET /huelseries/new.xml
  def new
    @huelseries = Huelserie.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @huelseries }
    end
  end

  # GET /huelseries/1/edit
  def edit
    @huelseries = Huelserie.find(params[:id])
  end

  # POST /huelseries
  # POST /huelseries.xml
  def create
    @huelseries = Huelserie.new(params[:huelseries])

    respond_to do |format|
      if @huelseries.save
        format.html { redirect_to(@huelseries, :notice => 'Huelserie was successfully created.') }
        format.xml  { render :xml => @huelseries, :status => :created, :location => @huelseries }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @huelseries.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /huelseries/1
  # PUT /huelseries/1.xml
  def update
    @huelseries = Huelserie.find(params[:id])

    respond_to do |format|
      if @huelseries.update_attributes(params[:huelseries])
        format.html { redirect_to(@huelseries, :notice => 'Huelserie was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @huelseries.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /huelseries/1
  # DELETE /huelseries/1.xml
  def destroy
    @huelseries = Huelserie.find(params[:id])
    @huelseries.destroy

    respond_to do |format|
      format.html { redirect_to(huelseries_url) }
      format.xml  { head :ok }
    end
  end
end
