class RubyInterfacesController < ApplicationController
  # GET /ruby_interfaces
  # GET /ruby_interfaces.xml
  def index
    @ruby_interfaces = RubyInterface.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ruby_interfaces }
    end
  end

  # GET /ruby_interfaces/1
  # GET /ruby_interfaces/1.xml
  def show
    @ruby_interface = RubyInterface.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ruby_interface }
    end
  end

  # GET /ruby_interfaces/new
  # GET /ruby_interfaces/new.xml
  def new
    @ruby_interface = RubyInterface.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ruby_interface }
    end
  end

  # GET /ruby_interfaces/1/edit
  def edit
    @ruby_interface = RubyInterface.find(params[:id])
  end

  # POST /ruby_interfaces
  # POST /ruby_interfaces.xml
  def create
    @ruby_interface = RubyInterface.new(params[:ruby_interface])

    respond_to do |format|
      if @ruby_interface.save
        format.html { redirect_to(@ruby_interface, :notice => 'Ruby interface was successfully created.') }
        format.xml  { render :xml => @ruby_interface, :status => :created, :location => @ruby_interface }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ruby_interface.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ruby_interfaces/1
  # PUT /ruby_interfaces/1.xml
  def update
    @ruby_interface = RubyInterface.find(params[:id])

    respond_to do |format|
      if @ruby_interface.update_attributes(params[:ruby_interface])
        format.html { redirect_to(@ruby_interface, :notice => 'Ruby interface was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ruby_interface.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ruby_interfaces/1
  # DELETE /ruby_interfaces/1.xml
  def destroy
    @ruby_interface = RubyInterface.find(params[:id])
    @ruby_interface.destroy

    respond_to do |format|
      format.html { redirect_to(ruby_interfaces_url) }
      format.xml  { head :ok }
    end
  end
end
