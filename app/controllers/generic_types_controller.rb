class GenericTypesController < ApplicationController
  # GET /generic_types
  # GET /generic_types.xml
  def index
    @generic_types = GenericType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @generic_types }
    end
  end

  # GET /generic_types/1
  # GET /generic_types/1.xml
  def show
    @generic_type = GenericType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @generic_type }
    end
  end

  # GET /generic_types/new
  # GET /generic_types/new.xml
  def new
    @generic_type = GenericType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @generic_type }
    end
  end

  # GET /generic_types/1/edit
  def edit
    @generic_type = GenericType.find(params[:id])
  end

  # POST /generic_types
  # POST /generic_types.xml
  def create
    @generic_type = GenericType.new(params[:generic_type])

    respond_to do |format|
      if @generic_type.save
        format.html { redirect_to(@generic_type, :notice => 'Generic type was successfully created.') }
        format.xml  { render :xml => @generic_type, :status => :created, :location => @generic_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @generic_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /generic_types/1
  # PUT /generic_types/1.xml
  def update
    @generic_type = GenericType.find(params[:id])

    respond_to do |format|
      if @generic_type.update_attributes(params[:generic_type])
        format.html { redirect_to(@generic_type, :notice => 'Generic type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @generic_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_types/1
  # DELETE /generic_types/1.xml
  def destroy
    @generic_type = GenericType.find(params[:id])
    @generic_type.destroy

    respond_to do |format|
      format.html { redirect_to(generic_types_url) }
      format.xml  { head :ok }
    end
  end
end
