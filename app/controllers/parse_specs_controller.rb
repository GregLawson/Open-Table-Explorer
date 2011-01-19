class ParseSpecsController < ApplicationController
  # GET /parse_specs
  # GET /parse_specs.xml
  def index
    @parse_specs = ParseSpec.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @parse_specs }
    end
  end

  # GET /parse_specs/1
  # GET /parse_specs/1.xml
  def show
    @parse_spec = ParseSpec.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @parse_spec }
    end
  end

  # GET /parse_specs/new
  # GET /parse_specs/new.xml
  def new
    @parse_spec = ParseSpec.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @parse_spec }
    end
  end

  # GET /parse_specs/1/edit
  def edit
    @parse_spec = ParseSpec.find(params[:id])
  end

  # POST /parse_specs
  # POST /parse_specs.xml
  def create
    @parse_spec = ParseSpec.new(params[:parse_spec])

    respond_to do |format|
      if @parse_spec.save
        flash[:notice] = 'ParseSpec was successfully created.'
        format.html { redirect_to(@parse_spec) }
        format.xml  { render :xml => @parse_spec, :status => :created, :location => @parse_spec }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @parse_spec.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /parse_specs/1
  # PUT /parse_specs/1.xml
  def update
    @parse_spec = ParseSpec.find(params[:id])

    respond_to do |format|
      if @parse_spec.update_attributes(params[:parse_spec])
        flash[:notice] = 'ParseSpec was successfully updated.'
        format.html { redirect_to(@parse_spec) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @parse_spec.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /parse_specs/1
  # DELETE /parse_specs/1.xml
  def destroy
    @parse_spec = ParseSpec.find(params[:id])
    @parse_spec.destroy

    respond_to do |format|
      format.html { redirect_to(parse_specs_url) }
      format.xml  { head :ok }
    end
  end
end
