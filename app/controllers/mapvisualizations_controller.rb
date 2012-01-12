require 'matrix'

class MapvisualizationsController < ApplicationController

######## BEGIN CLASS DEFINITIONS #########
  ## Data structures for easier use 
  class Node < Object
    attr_accessor :id, :name, :weight, :location

    def initialize(id, name, weight)
      @id = id #needed? currently using index as an id; may need to tweak this as we start fetching from db
      @name = name
      @weight = weight
      @location = Vector[0,0]
    end
    
    def to_s
      @name.to_s + "("+@location.to_s+")"
    end

    #returns a javascript version of the object
    def js
      "{name:'"+@name+"',"+
      "x:"+@location[0].to_s+",y:"+@location[1].to_s+","+
      "weight:"+@weight.to_s+"}" 
      #can add more fields as needed
    end
    
  end  

  class Edge < Object
    attr_accessor :id, :a, :b, :weight, :type
    
    def initialize(id, a, b, weight)
      @id = id #needed?
      @a = a #reference to the node object (as opposed to just an index)
      @b = b
      @weight = weight
      @type = 0
    end
  
    def to_s
      @id.to_s+": Edge "+@a.to_s+" - "+@b.to_s
    end
    
    def name
      "Edge "+@a.name+" - "+@b.name
    end

    #returns a javascript version of the object 
    #ai and bi are the js indices for the connecting nodes (default to node's ID)
    #nodeset is the name of the js node array (default to "nodes")
    def js(ai=@a.id, bi=@b.id, nodeset='nodes') 
      "{name:'"+name+"',"+
      "a:"+nodeset+"["+ai.to_s+"],b:"+nodeset+"["+bi.to_s+"]"+","+
      "weight:"+@weight.to_s+"}"
      #can add more fields as needed
    end

  end
  
######## END CLASS DEFINITIONS #########  

  # the code run on index load
  # GET /mapvisualizations
  def index
    # @mapvisualizations = Mapvisualization.all
    node_count = 10

    @nodes = Array.new(node_count) {|i| Node.new(i, "Node "+i.to_s, rand()*5)} #make all the nodes (random)
    @edges = Array.new() #an array to hold edges
    @adjacency = Array.new(node_count) {|i| Array.new(node_count)} #an adjacency matrix of edges (for easy referencing)
    for i in (0..node_count-1)
      for j in (i+1..node_count-1)
        if(rand() > 0.8) #make random edges
          @edges.push(Edge.new(j*node_count+i, @nodes[i], @nodes[j], rand()*5))
          @adjacency[i][j] = @edges.last
          @adjacency[j][i] = @edges.last
        end
      end
    end
    
    circle_nodes(@nodes, 500, 500) #default circle nodes in 500x500 canvas? This method should be elsewhere...
  
  end


  # put the given nodes into a circle that will (mostly) fit in the given canvas
  def circle_nodes(nodeset, width, height)
    center = Vector[width/2, height/2]
    radius = 0.375*[width,height].min
    
    nodeset.each_index{|i| nodeset[i].location = Vector[
      center[0] + (radius * Math.cos(2*Math::PI*i/nodeset.length)), 
      center[1] + (radius * Math.sin(2*Math::PI*i/nodeset.length))]}
  end

  def force_layout(nodeset, width, height)
    #put the nodes in a force-based layout
  end

  



############################################################
### OLD RESTFUL METHODS
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
