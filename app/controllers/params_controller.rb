class ParamsController < ApplicationController
  # GET /params
  # GET /params.xml
  def index
    @params = Param.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @params }
    end
  end

  # GET /params/1
  # GET /params/1.xml
  def show
    @param = Param.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @param }
    end
  end

  # GET /params/new
  # GET /params/new.xml
  def new
    @param = Param.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @param }
    end
  end

  # GET /params/1/edit
  def edit
    @param = Param.find(params[:id])
  end

  # POST /params
  # POST /params.xml
  def create
    @param = Param.new(params[:param])

    respond_to do |format|
      if @param.save
        flash[:notice] = 'Param was successfully created.'
        format.html { redirect_to(@param) }
        format.xml  { render :xml => @param, :status => :created, :location => @param }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @param.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /params/1
  # PUT /params/1.xml
  def update
    @param = Param.find(params[:id])

    respond_to do |format|
      if @param.update_attributes(params[:param])
        flash[:notice] = 'Param was successfully updated.'
        format.html { redirect_to(@param) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @param.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /params/1
  # DELETE /params/1.xml
  def destroy
    @param = Param.find(params[:id])
    @param.destroy

    respond_to do |format|
      format.html { redirect_to(params_url) }
      format.xml  { head :ok }
    end
  end
end
