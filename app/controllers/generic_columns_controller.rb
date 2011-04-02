class GenericColumnsController < ApplicationController
  # GET /generic_columns
  # GET /generic_columns.xml
  def index
    @generic_columns = GenericColumn.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @generic_columns }
    end
  end

  # GET /generic_columns/1
  # GET /generic_columns/1.xml
  def show
    @generic_column = GenericColumn.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @generic_column }
    end
  end

  # GET /generic_columns/new
  # GET /generic_columns/new.xml
  def new
    @generic_column = GenericColumn.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @generic_column }
    end
  end

  # GET /generic_columns/1/edit
  def edit
    @generic_column = GenericColumn.find(params[:id])
  end

  # POST /generic_columns
  # POST /generic_columns.xml
  def create
    @generic_column = GenericColumn.new(params[:generic_column])

    respond_to do |format|
      if @generic_column.save
        flash[:notice] = 'GenericColumn was successfully created.'
        format.html { redirect_to(@generic_column) }
        format.xml  { render :xml => @generic_column, :status => :created, :location => @generic_column }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @generic_column.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /generic_columns/1
  # PUT /generic_columns/1.xml
  def update
    @generic_column = GenericColumn.find(params[:id])

    respond_to do |format|
      if @generic_column.update_attributes(params[:generic_column])
        flash[:notice] = 'GenericColumn was successfully updated.'
        format.html { redirect_to(@generic_column) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @generic_column.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_columns/1
  # DELETE /generic_columns/1.xml
  def destroy
    @generic_column = GenericColumn.find(params[:id])
    @generic_column.destroy

    respond_to do |format|
      format.html { redirect_to(generic_columns_url) }
      format.xml  { head :ok }
    end
  end
end
