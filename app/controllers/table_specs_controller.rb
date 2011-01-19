class TableSpecsController < ApplicationController
  # GET /table_specs
  # GET /table_specs.xml
  def index
    @table_specs = TableSpec.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @table_specs }
    end
  end

  # GET /table_specs/1
  # GET /table_specs/1.xml
  def show
    @table_spec = TableSpec.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @table_spec }
    end
  end

  # GET /table_specs/new
  # GET /table_specs/new.xml
  def new
    @table_spec = TableSpec.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @table_spec }
    end
  end

  # GET /table_specs/1/edit
  def edit
    @table_spec = TableSpec.find(params[:id])
  end

  # POST /table_specs
  # POST /table_specs.xml
  def create
    @table_spec = TableSpec.new(params[:table_spec])

    respond_to do |format|
      if @table_spec.save
        flash[:notice] = 'TableSpec was successfully created.'
        format.html { redirect_to(@table_spec) }
        format.xml  { render :xml => @table_spec, :status => :created, :location => @table_spec }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @table_spec.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /table_specs/1
  # PUT /table_specs/1.xml
  def update
    @table_spec = TableSpec.find(params[:id])

    respond_to do |format|
      if @table_spec.update_attributes(params[:table_spec])
        flash[:notice] = 'TableSpec was successfully updated.'
        format.html { redirect_to(@table_spec) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @table_spec.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /table_specs/1
  # DELETE /table_specs/1.xml
  def destroy
    @table_spec = TableSpec.find(params[:id])
    @table_spec.destroy

    respond_to do |format|
      format.html { redirect_to(table_specs_url) }
      format.xml  { head :ok }
    end
  end
end
