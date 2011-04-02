class ExampleTypesController < ApplicationController
  # GET /example_types
  # GET /example_types.xml
  def index
    @example_types = ExampleType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @example_types }
    end
  end

  # GET /example_types/1
  # GET /example_types/1.xml
  def show
    @example_type = ExampleType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @example_type }
    end
  end

  # GET /example_types/new
  # GET /example_types/new.xml
  def new
    @example_type = ExampleType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @example_type }
    end
  end

  # GET /example_types/1/edit
  def edit
    @example_type = ExampleType.find(params[:id])
  end

  # POST /example_types
  # POST /example_types.xml
  def create
    @example_type = ExampleType.new(params[:example_type])

    respond_to do |format|
      if @example_type.save
        format.html { redirect_to(@example_type, :notice => 'Example type was successfully created.') }
        format.xml  { render :xml => @example_type, :status => :created, :location => @example_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @example_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /example_types/1
  # PUT /example_types/1.xml
  def update
    @example_type = ExampleType.find(params[:id])

    respond_to do |format|
      if @example_type.update_attributes(params[:example_type])
        format.html { redirect_to(@example_type, :notice => 'Example type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @example_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /example_types/1
  # DELETE /example_types/1.xml
  def destroy
    @example_type = ExampleType.find(params[:id])
    @example_type.destroy

    respond_to do |format|
      format.html { redirect_to(example_types_url) }
      format.xml  { head :ok }
    end
  end
end
