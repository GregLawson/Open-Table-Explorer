class RoutersController < ApplicationController
  # GET /routers
  # GET /routers.xml
  def index
    @routers = Router.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @routers }
    end
  end

  # GET /routers/1
  # GET /routers/1.xml
  def show
    @router = Router.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @router }
    end
  end

  # GET /routers/new
  # GET /routers/new.xml
  def new
    @router = Router.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @router }
    end
  end

  # GET /routers/1/edit
  def edit
    @router = Router.find(params[:id])
  end

  # POST /routers
  # POST /routers.xml
  def create
    @router = Router.new(params[:router])

    respond_to do |format|
      if @router.save
        flash[:notice] = 'Router was successfully created.'
        format.html { redirect_to(@router) }
        format.xml  { render :xml => @router, :status => :created, :location => @router }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @router.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /routers/1
  # PUT /routers/1.xml
  def update
    @router = Router.find(params[:id])

    respond_to do |format|
      if @router.update_attributes(params[:router])
        flash[:notice] = 'Router was successfully updated.'
        format.html { redirect_to(@router) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @router.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /routers/1
  # DELETE /routers/1.xml
  def destroy
    @router = Router.find(params[:id])
    @router.destroy

    respond_to do |format|
      format.html { redirect_to(routers_url) }
      format.xml  { head :ok }
    end
  end
end
