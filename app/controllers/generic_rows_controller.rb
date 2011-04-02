class GenericRowsController < ApplicationController
  # GET /generic_rows
  # GET /generic_rows.xml
  def index
    @generic_rows = GenericRow.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @generic_rows }
    end
  end

  # GET /generic_rows/1
  # GET /generic_rows/1.xml
  def show
    @generic_row = GenericRow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @generic_row }
    end
  end

  # GET /generic_rows/new
  # GET /generic_rows/new.xml
  def new
    @generic_row = GenericRow.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @generic_row }
    end
  end

  # GET /generic_rows/1/edit
  def edit
    @generic_row = GenericRow.find(params[:id])
  end

  # POST /generic_rows
  # POST /generic_rows.xml
  def create
    @generic_row = GenericRow.new(params[:generic_row])

    respond_to do |format|
      if @generic_row.save
        flash[:notice] = 'GenericRow was successfully created.'
        format.html { redirect_to(@generic_row) }
        format.xml  { render :xml => @generic_row, :status => :created, :location => @generic_row }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @generic_row.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /generic_rows/1
  # PUT /generic_rows/1.xml
  def update
    @generic_row = GenericRow.find(params[:id])

    respond_to do |format|
      if @generic_row.update_attributes(params[:generic_row])
        flash[:notice] = 'GenericRow was successfully updated.'
        format.html { redirect_to(@generic_row) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @generic_row.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_rows/1
  # DELETE /generic_rows/1.xml
  def destroy
    @generic_row = GenericRow.find(params[:id])
    @generic_row.destroy

    respond_to do |format|
      format.html { redirect_to(generic_rows_url) }
      format.xml  { head :ok }
    end
  end
end
