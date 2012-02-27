class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
    @paths = Path.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @paths }
    end
  end

  # GET /paths/1
  # GET /paths/1.xml
  def show
    @path = Path.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @path }
    end
  end

  # GET /paths/new
  # GET /paths/new.xml
  def new
    @path = Path.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @path }
    end
  end

  # GET /paths/1/edit
  def edit
    @path = Path.find(params[:id])
  end

  # POST /paths
  # POST /paths.xml
  def create
    @path = Path.new(params[:path])

    respond_to do |format|
      if @path.save
        format.html { redirect_to(@path, :notice => 'Path was successfully created.') }
        format.xml  { render :xml => @path, :status => :created, :location => @path }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @path.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /paths/1
  # PUT /paths/1.xml
  def update
    @path = Path.find(params[:id])

    respond_to do |format|
      if @path.update_attributes(params[:path])
        format.html { redirect_to(@path, :notice => 'Path was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @path.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /paths/1
  # DELETE /paths/1.xml
  def destroy
    @path = Path.find(params[:id])
    @path.destroy

    respond_to do |format|
      format.html { redirect_to(paths_url) }
      format.xml  { head :ok }
    end
  end
end
