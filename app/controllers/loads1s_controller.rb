class Loads1sController < ApplicationController
  # GET /loads1s
  # GET /loads1s.xml
  def index
    @loads1s = Loads1.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @loads1s }
    end
  end

  # GET /loads1s/1
  # GET /loads1s/1.xml
  def show
    @loads1 = Loads1.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @loads1 }
    end
  end

  # GET /loads1s/new
  # GET /loads1s/new.xml
  def new
    @loads1 = Loads1.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @loads1 }
    end
  end

  # GET /loads1s/1/edit
  def edit
    @loads1 = Loads1.find(params[:id])
  end

  # POST /loads1s
  # POST /loads1s.xml
  def create
    @loads1 = Loads1.new(params[:loads1])

    respond_to do |format|
      if @loads1.save
        flash[:notice] = 'Loads1 was successfully created.'
        format.html { redirect_to(@loads1) }
        format.xml  { render :xml => @loads1, :status => :created, :location => @loads1 }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @loads1.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /loads1s/1
  # PUT /loads1s/1.xml
  def update
    @loads1 = Loads1.find(params[:id])

    respond_to do |format|
      if @loads1.update_attributes(params[:loads1])
        flash[:notice] = 'Loads1 was successfully updated.'
        format.html { redirect_to(@loads1) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @loads1.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /loads1s/1
  # DELETE /loads1s/1.xml
  def destroy
    @loads1 = Loads1.find(params[:id])
    @loads1.destroy

    respond_to do |format|
      format.html { redirect_to(loads1s_url) }
      format.xml  { head :ok }
    end
  end
end
