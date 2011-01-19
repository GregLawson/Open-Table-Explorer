class TedprimariesController < ApplicationController
  # GET /tedprimaries
  # GET /tedprimaries.xml
  def index
    @tedprimaries = Tedprimary.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tedprimaries }
    end
  end

  # GET /tedprimaries/1
  # GET /tedprimaries/1.xml
  def show
    @tedprimary = Tedprimary.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tedprimary }
    end
  end

  # GET /tedprimaries/new
  # GET /tedprimaries/new.xml
  def new
    @tedprimary = Tedprimary.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tedprimary }
    end
  end

  # GET /tedprimaries/1/edit
  def edit
    @tedprimary = Tedprimary.find(params[:id])
  end

  # POST /tedprimaries
  # POST /tedprimaries.xml
  def create
    @tedprimary = Tedprimary.new(params[:tedprimary])

    respond_to do |format|
      if @tedprimary.save
        flash[:notice] = 'Tedprimary was successfully created.'
        format.html { redirect_to(@tedprimary) }
        format.xml  { render :xml => @tedprimary, :status => :created, :location => @tedprimary }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tedprimary.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tedprimaries/1
  # PUT /tedprimaries/1.xml
  def update
    @tedprimary = Tedprimary.find(params[:id])

    respond_to do |format|
      if @tedprimary.update_attributes(params[:tedprimary])
        flash[:notice] = 'Tedprimary was successfully updated.'
        format.html { redirect_to(@tedprimary) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tedprimary.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tedprimaries/1
  # DELETE /tedprimaries/1.xml
  def destroy
    @tedprimary = Tedprimary.find(params[:id])
    @tedprimary.destroy

    respond_to do |format|
      format.html { redirect_to(tedprimaries_url) }
      format.xml  { head :ok }
    end
  end
end
