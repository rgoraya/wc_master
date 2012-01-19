require 'matrix'

class Mapvisualization #< ActiveRecord::Base
  # include ActiveModel::Validations #do I need any of this?
  # include ActiveModel::Conversion
  # extend ActiveModel::Naming

  ######## BEGIN SUBCLASS DEFINITIONS #########
  ## Data structures for easier use 
  class Node < Object
    attr_accessor :id, :name, :weight, :location, :d, :a

    def initialize(id, name, weight)
      @id = id #needed? currently using index as an id; may need to tweak this as we start fetching from db
      @name = name
      @weight = weight
      @location = Vector[0.0,0.0]
      @d = Vector[0.0,0.0] #delta variable
      @a = Vector[0.0,0.0] #accelration variable
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
  
  def initialize(args)
    @width, @height = args[:width], args[:height]
    
    puts args
    
    @nodes = args[:nodes]
    @edges = args[:edges]
    
    reset_graph(@width, @height, args) if @nodes.nil? #currently resets to random

    # random_graph(args[:node_count]) #init to random graph atm
    #normally will init to pull out the nodes we want to see... or something. Will need to figure out how that works
  end

  

  def random_graph(node_count, edge_ratio)
    puts "edge_ratio=" + edge_ratio.to_s
    @nodes = Array.new(node_count) {|i| Node.new(i, "Node "+i.to_s, rand()*5)} #make all the nodes (random)
    @edges = Array.new() #an array to hold edges
    @adjacency = Array.new(node_count) {|i| Array.new(node_count)} #an adjacency matrix of edges (for easy referencing)
    for i in (0..node_count-1)
      for j in (i+1..node_count-1)
        if(rand() < edge_ratio) #make random edges
          @edges.push(Edge.new(j*node_count+i, @nodes[i], @nodes[j], rand()*5))
          puts "adding edges, length now equal to "+ @edges.length.to_s
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

  # adapted from https://github.com/dhotson/springy/blob/master/springy.js
  def springy(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    puts "springy called"
    for n in nodeset
      # convert to "close" coordinates (to within 4x4 bounding box, in this case)
      n.location = Vector[4.0*n.location[0]/width - 2.0, 4.0*n.location[1]/height - 2.0]
      n.d = Vector[0.0,0.0] #clear out previous movement before we begin... sure
      n.a = Vector[0.0,0.0] 
    end
    stiffness = 400.0 #what exactly will these variables do?
    repulsion = 400.0
    damping = 0.5
    timestep = 0.03

    prevEnergy = 0.0
    currEnergy = 1.0
    iters = 0
    until currEnergy < 0.01 or (currEnergy-prevEnergy).abs < 0.00001 or iters > 1000 do #energy threshold?
      prevEnergy = currEnergy
      #for n1 in nodeset #apply Coulomb's Law
      nodeset.each_index do |i|
        n1 = nodeset[i]
        nodeset.each_index do |j|
          n2 = nodeset[j]
          if i != j
            #puts "applying coulomb to " + n1.to_s + " and " + n2.to_s #should this be once per pair?
            d = n1.location - n2.location
            distance = d.r + 0.1 #avoid massive forces at small distances (and divide by zero)
            direction = d/d.r #normalized
            n1.a += direction*(repulsion/(distance*distance*0.5))/1.0 #divide by "mass" (currently 1)
            n2.a += direction*(repulsion/(distance*distance*-0.5))/1.0 #divide by "mass" (currently 1)          
          end
        end
      end      

      for e in edgeset #apply Hooke's Law
        #puts "applying hooke's law to "+e.to_s
        d = e.b.location - e.a.location
        displacement = 1.0 - d.r #spring "length" at rest?? - magnitude... either 0 or 1 or ?
        direction = d/d.r #normalized
        e.a.a += direction*(stiffness*displacement*-0.5)/1.0 #divide by the "mass" (currently 1)
        e.b.a += direction*(stiffness*displacement*0.5)/1.0
      end

      # for n in nodeset
      #   puts n.to_s + " accel: "+ n.a.to_s #seems large... but maybe because of how 
      # end

      for n in nodeset #finish moving nodes/etc
        n.a += (n.location*-1)*(repulsion/50.0)/1.0 #attract to center
        #puts n.to_s + " accel: "+ n.a.to_s
        n.d += n.a*timestep*damping #update velocity
        #puts n.to_s + " veloc: "+ n.d.to_s
        n.a = Vector[0.0,0.0] #reset acceleration
        n.location += n.d*timestep #update position        
        #puts n.to_s + " loc: "+ n.location.to_s
      end

      scale = Vector[ 2.0/[nodeset.max_by{|n| n.location[0].abs}.location[0].abs,2.0].max , 
                      2.0/[nodeset.max_by{|n| n.location[1].abs}.location[1].abs,2.0].max ] #biggest coords
      currEnergy = 0.0
      for n in nodeset
        n.location = Vector[n.location[0]*scale[0], n.location[1]*scale[1]] ##rescale to stay within bounds!
        n.d = Vector[n.d[0]*scale[0], n.d[1]*scale[1]]
        # puts n.to_s + " loc: "+ n.location.to_s
        currEnergy += 0.5*1.0*n.d.r**2 #calculate total energy; 1.0=mass
      end
            
      # calc delta energy, and use that for stopping?
      puts "end of loop "+iters.to_s+", energy=" + currEnergy.to_s
      iters+=1
    end
    for n in nodeset # convert back to "screen" coordinates (from within 4x4 bounding box, in this case, with 50px border)
      n.location = Vector[((n.location[0]+2)/4.0)*(width-100)+50,((n.location[1]+2)/4.0)*(height-100)+50]
    end    
  end

  def kamada_kawai(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)

  end

  def reset_graph(width=@width, height=@height, args)
    random_graph(args[:node_count].to_i, args[:edge_ratio].to_f) #default amount
    place_randomly
  end
  
  def remove_edges(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    edgeset.clear #clear the edges for testing
  end

  def force_layout(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    fruchterman_reingold #can specify particular layouts here if we wanted...
  end


end
