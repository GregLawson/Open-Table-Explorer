class OfxesController < ApplicationController
  # GET /ofxes
  # GET /ofxes.xml
  def index
    @ofxes = Ofx.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ofxes }
    end
  end

  # GET /ofxes/1
  # GET /ofxes/1.xml
  def show
    @ofx = Ofx.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ofx }
    end
  end

  # GET /ofxes/new
  # GET /ofxes/new.xml
  def new
    @ofx = Ofx.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ofx }
    end
  end

  # GET /ofxes/1/edit
  def edit
    @ofx = Ofx.find(params[:id])
  end

  # POST /ofxes
  # POST /ofxes.xml
  def create
    @ofx = Ofx.new(params[:ofx])

    respond_to do |format|
      if @ofx.save
        format.html { redirect_to(@ofx, :notice => 'Ofx was successfully created.') }
        format.xml  { render :xml => @ofx, :status => :created, :location => @ofx }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ofx.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ofxes/1
  # PUT /ofxes/1.xml
  def update
    @ofx = Ofx.find(params[:id])

    respond_to do |format|
      if @ofx.update_attributes(params[:ofx])
        format.html { redirect_to(@ofx, :notice => 'Ofx was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ofx.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ofxes/1
  # DELETE /ofxes/1.xml
  def destroy
    @ofx = Ofx.find(params[:id])
    @ofx.destroy

    respond_to do |format|
      format.html { redirect_to(ofxes_url) }
      format.xml  { head :ok }
    end
  end
end
