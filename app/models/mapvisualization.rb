require 'matrix'

class Mapvisualization #< ActiveRecord::Base
  # include ActiveModel::Validations #do I need any of this?
  # include ActiveModel::Conversion
  # extend ActiveModel::Naming

  ######## BEGIN SUBCLASS DEFINITIONS #########
  ## Data structures for easier use 
  class Node < Object
    attr_accessor :id, :name, :weight, :location, :d

    def initialize(id, name, weight)
      @id = id #needed? currently using index as an id; may need to tweak this as we start fetching from db
      @name = name
      @weight = weight
      @location = Vector[0.0,0.0]
      @d = Vector[0.0,0.0] #delta variable
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

  attr_accessor :nodes, :edges, :width, :height
  
  def initialize(width, height, num_nodes)
    @width, @height = width, height

    random_graph(num_nodes) #init to random graph atm
    #normally will init to pull out the nodes we want to see... or something. Will need to figure out how that works

    circle_nodes(@width, @height)
  end

  def random_graph(node_count)
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
  end

  # put the nodes into a circle that will (mostly) fit in the given canvas
  def circle_nodes(width=@width, height=@height, nodeset=@nodes)
    center = Vector[width/2, height/2]
    radius = 0.375*[width,height].min
    nodeset.each_index{|i| nodeset[i].location = Vector[
      center[0] + (radius * Math.cos(2*Math::PI*i/nodeset.length)), 
      center[1] + (radius * Math.sin(2*Math::PI*i/nodeset.length))]}
  end

  #put the nodes in random locations

  def place_randomly(width=@width, height=@height, nodeset=@nodes)
    for node in nodeset
      node.location = Vector[50+rand(width-100), 50+rand(height-100)]
    end
  end

  # algorithm from fruchterman_reingold via Kobourov 2004
  def fruchterman_reingold(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    puts "f_r called"
    iterations = 500
    area = width*height
    k = nodeset.length > 0 ? Math.sqrt(area/nodeset.length) : 1 #multiply this by .75 to slow it down?
    k2 = k**2
    temperature = width/10
    for i in (1..iterations) do
      for v in nodeset do #calc repulsive forces
        v.d = Vector[0.0,0.0]
        for u in nodeset do
          if u!=v
            dist = v.location - u.location
            distlen = dist.r.to_f
            v.d += distlen != 0.0 ? (dist/distlen)*k2/distlen : Vector[0.0,0.0]
          end
        end
      end
      for e in edgeset do #calc attractive forces
        dist = e.a.location - e.b.location
        distlen = dist.r.to_f
        fa = distlen**2/k
        e.a.d -= (dist/distlen)*fa
        e.b.d += (dist/distlen)*fa
      end
      #puts nodeset
      for v in nodeset do #move nodes
        #added in attraction to center
        dist_center = v.location - Vector[width/2, height/2]
        distlen = dist_center.r.to_f
        fa = distlen**2/k
        v.d -= (dist_center/distlen)*fa

        dlen = v.d.r.to_f
        if dlen > 0.0 #if we have a distance to move
          v.location += (v.d/dlen)*[dlen,temperature].min
          nx = [[v.location[0],50].max, width-50].min #don't let outside of bounds (50px border)
          ny = [[v.location[1],50].max, height-50].min
          v.location = Vector[nx,ny]
        end
      end
      temperature *= (1 - i/iterations.to_f) #cooling function from http://goo.gl/xcbXR
    end
  end



  def reset_graph(width=@width, height=@height, args)
    random_graph(args[:node_count].to_i)
    place_randomly
  end
  
  def remove_edges(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    edgeset.clear #clear the edges for testing
  end

  def force_layout(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    fruchterman_reingold #can specify particular layouts here if we wanted...
  end


end
