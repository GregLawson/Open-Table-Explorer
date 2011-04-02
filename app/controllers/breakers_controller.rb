class BreakersController < ApplicationController
  # GET /breakers
  # GET /breakers.xml
  def index
    @breakers = Breaker.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @breakers }
    end
  end

  # GET /breakers/1
  # GET /breakers/1.xml
  def show
    @breaker = Breaker.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @breaker }
    end
  end

  # GET /breakers/new
  # GET /breakers/new.xml
  def new
    @breaker = Breaker.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @breaker }
    end
  end

  # GET /breakers/1/edit
  def edit
    @breaker = Breaker.find(params[:id])
  end

  # POST /breakers
  # POST /breakers.xml
  def create
    @breaker = Breaker.new(params[:breaker])

    respond_to do |format|
      if @breaker.save
        flash[:notice] = 'Breaker was successfully created.'
        format.html { redirect_to(@breaker) }
        format.xml  { render :xml => @breaker, :status => :created, :location => @breaker }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @breaker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /breakers/1
  # PUT /breakers/1.xml
  def update
    @breaker = Breaker.find(params[:id])

    respond_to do |format|
      if @breaker.update_attributes(params[:breaker])
        flash[:notice] = 'Breaker was successfully updated.'
        format.html { redirect_to(@breaker) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @breaker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /breakers/1
  # DELETE /breakers/1.xml
  def destroy
    @breaker = Breaker.find(params[:id])
    @breaker.destroy

    respond_to do |format|
      format.html { redirect_to(breakers_url) }
      format.xml  { head :ok }
    end
  end
end
