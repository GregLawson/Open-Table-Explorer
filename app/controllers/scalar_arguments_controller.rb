class ScalarArgumentsController < ApplicationController
  # GET /scalar_arguments
  # GET /scalar_arguments.xml
  def index
    @scalar_arguments = ScalarArgument.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scalar_arguments }
    end
  end

  # GET /scalar_arguments/1
  # GET /scalar_arguments/1.xml
  def show
    @scalar_argument = ScalarArgument.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scalar_argument }
    end
  end

  # GET /scalar_arguments/new
  # GET /scalar_arguments/new.xml
  def new
    @scalar_argument = ScalarArgument.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scalar_argument }
    end
  end

  # GET /scalar_arguments/1/edit
  def edit
    @scalar_argument = ScalarArgument.find(params[:id])
  end

  # POST /scalar_arguments
  # POST /scalar_arguments.xml
  def create
    @scalar_argument = ScalarArgument.new(params[:scalar_argument])

    respond_to do |format|
      if @scalar_argument.save
        format.html { redirect_to(@scalar_argument, :notice => 'Scalar argument was successfully created.') }
        format.xml  { render :xml => @scalar_argument, :status => :created, :location => @scalar_argument }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scalar_argument.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scalar_arguments/1
  # PUT /scalar_arguments/1.xml
  def update
    @scalar_argument = ScalarArgument.find(params[:id])

    respond_to do |format|
      if @scalar_argument.update_attributes(params[:scalar_argument])
        format.html { redirect_to(@scalar_argument, :notice => 'Scalar argument was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scalar_argument.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scalar_arguments/1
  # DELETE /scalar_arguments/1.xml
  def destroy
    @scalar_argument = ScalarArgument.find(params[:id])
    @scalar_argument.destroy

    respond_to do |format|
      format.html { redirect_to(scalar_arguments_url) }
      format.xml  { head :ok }
    end
  end
end
