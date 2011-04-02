class ProductionFtpsController < ApplicationController
  # GET /production_ftps
  # GET /production_ftps.xml
  def index
    @production_ftps = ProductionFtp.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @production_ftps }
    end
  end

  # GET /production_ftps/1
  # GET /production_ftps/1.xml
  def show
    @production_ftp = ProductionFtp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @production_ftp }
    end
  end

  # GET /production_ftps/new
  # GET /production_ftps/new.xml
  def new
    @production_ftp = ProductionFtp.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @production_ftp }
    end
  end

  # GET /production_ftps/1/edit
  def edit
    @production_ftp = ProductionFtp.find(params[:id])
  end

  # POST /production_ftps
  # POST /production_ftps.xml
  def create
    @production_ftp = ProductionFtp.new(params[:production_ftp])

    respond_to do |format|
      if @production_ftp.save
        format.html { redirect_to(@production_ftp, :notice => 'Production ftp was successfully created.') }
        format.xml  { render :xml => @production_ftp, :status => :created, :location => @production_ftp }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @production_ftp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /production_ftps/1
  # PUT /production_ftps/1.xml
  def update
    @production_ftp = ProductionFtp.find(params[:id])

    respond_to do |format|
      if @production_ftp.update_attributes(params[:production_ftp])
        format.html { redirect_to(@production_ftp, :notice => 'Production ftp was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @production_ftp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /production_ftps/1
  # DELETE /production_ftps/1.xml
  def destroy
    @production_ftp = ProductionFtp.find(params[:id])
    @production_ftp.destroy

    respond_to do |format|
      format.html { redirect_to(production_ftps_url) }
      format.xml  { head :ok }
    end
  end
end
