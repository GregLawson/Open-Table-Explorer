class TestRunsController < ApplicationController
  # GET /test_runs
  # GET /test_runs.xml
  def index
    @test_runs = TestRun.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @test_runs }
    end
  end

  # GET /test_runs/1
  # GET /test_runs/1.xml
  def show
    @test_run = TestRun.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @test_run }
    end
  end

  # GET /test_runs/new
  # GET /test_runs/new.xml
  def new
    @test_run = TestRun.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @test_run }
    end
  end

  # GET /test_runs/1/edit
  def edit
    @test_run = TestRun.find(params[:id])
  end

  # POST /test_runs
  # POST /test_runs.xml
  def create
    @test_run = TestRun.new(params[:test_run])

    respond_to do |format|
      if @test_run.save
        format.html { redirect_to(@test_run, :notice => 'Test run was successfully created.') }
        format.xml  { render :xml => @test_run, :status => :created, :location => @test_run }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @test_run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /test_runs/1
  # PUT /test_runs/1.xml
  def update
    @test_run = TestRun.find(params[:id])

    respond_to do |format|
      if @test_run.update_attributes(params[:test_run])
        format.html { redirect_to(@test_run, :notice => 'Test run was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @test_run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /test_runs/1
  # DELETE /test_runs/1.xml
  def destroy
    @test_run = TestRun.find(params[:id])
    @test_run.destroy

    respond_to do |format|
      format.html { redirect_to(test_runs_url) }
      format.xml  { head :ok }
    end
  end
end
