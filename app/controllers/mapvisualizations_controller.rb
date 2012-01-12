class MapvisualizationsController < ApplicationController
  # GET /mapvisualizations
  # GET /mapvisualizations.xml
  def index
    @mapvisualizations = Mapvisualization.all

    # do method calls / variable declarations here

    @my_var = 12 #testing variable
     





    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mapvisualizations }
    end
  end


#DEFINE NEW METHOD CALLS IF NEEEDED





############################################################


  # GET /mapvisualizations/1
  # GET /mapvisualizations/1.xml
  def show
    @mapvisualization = Mapvisualization.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mapvisualization }
    end
  end

  # GET /mapvisualizations/new
  # GET /mapvisualizations/new.xml
  def new
    @mapvisualization = Mapvisualization.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mapvisualization }
    end
  end

  # GET /mapvisualizations/1/edit
  def edit
    @mapvisualization = Mapvisualization.find(params[:id])
  end

  # POST /mapvisualizations
  # POST /mapvisualizations.xml
  def create
    @mapvisualization = Mapvisualization.new(params[:mapvisualization])

    respond_to do |format|
      if @mapvisualization.save
        format.html { redirect_to(@mapvisualization, :notice => 'Mapvisualization was successfully created.') }
        format.xml  { render :xml => @mapvisualization, :status => :created, :location => @mapvisualization }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mapvisualization.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mapvisualizations/1
  # PUT /mapvisualizations/1.xml
  def update
    @mapvisualization = Mapvisualization.find(params[:id])

    respond_to do |format|
      if @mapvisualization.update_attributes(params[:mapvisualization])
        format.html { redirect_to(@mapvisualization, :notice => 'Mapvisualization was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mapvisualization.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mapvisualizations/1
  # DELETE /mapvisualizations/1.xml
  def destroy
    @mapvisualization = Mapvisualization.find(params[:id])
    @mapvisualization.destroy

    respond_to do |format|
      format.html { redirect_to(mapvisualizations_url) }
      format.xml  { head :ok }
    end
  end
end
