require 'matrix'

class Mapvisualization #< ActiveRecord::Base
  # include ActiveModel::Validations #do I need any of this?
  # include ActiveModel::Conversion
  # extend ActiveModel::Naming

######## BEGIN SUBCLASS DEFINITIONS #########
  ## Data structures for easier use 
  class Node < Object
    attr_accessor :id, :name, :url, :location, :d, :a

    def initialize(id, name, url)
      @id = id #db-level index
      @name = name
      @url = url
      @location = Vector[0.0,0.0]
      @d = Vector[0.0,0.0] #delta variable
      @a = Vector[0.0,0.0] #accelration variable
    end

    def to_s
      @name.to_s + "("+@location.to_s+")"
    end

    #returns a javascript version of the object
    def js(offset=0)
      "{id:"+@id.to_s+","+
      "name:'"+@name+"',"+
      "x:"+(@location[0]+offset).to_s+",y:"+(@location[1]+offset).to_s+","+
      "url:'"+@url+"'}"
      #can add more fields as needed
    end

    #returns a unique javascript key for the node object
    def js_k
      @id.to_s
    end
      
  end  

  class Edge < Object
    attr_accessor :id, :a, :b, :rel_type

    # NOTES ON FORM:
    #   Each "edge" object consists of a single line (relationship)
    #   edges also have parameters describing what they do (pointers for drawing)
    #   -- when drawing will have to determine if we need to "arc" or not (only if >1 relationship between nodes), and don't do the neural net thing
    #       - solvable problem; can calc and pass in the adjacency matrix as a counter for example
    #       - which is fine because we're probably constructing this anyway, and would let the "curve" functionality be isolated for later
    #   ++ each javascript object can have a different interaction associated with it easily
    

    ## IF these change, remember to alter in javascript!
    INCREASES = 1 #constants for relationship type
    #DECREASE = 2 #if we wanted to have this be not mutually inclusive
    EXPANDABLE = 4
    HIGHLIGHTED = 8
    
    #dimensions: A->B or B->A; incr or decr; expand or not; highlighted or not

    def initialize(id, a, b, rel_type=1)
      @id = id #needed?
      @a = a #reference to the node object (as opposed to just an index)
      @b = b
      @rel_type = rel_type  #specified edge.reltype
    end

    def to_s
      @id.to_s+": Edge "+@a.to_s+" - "+@b.to_s
    end

    def name
      "Edge "+@a.name+" - "+@b.name
    end

    #returns a javascript version of the object 
    #nodeset is the name of the js node array (default to "nodes")
    #(a and b are references into the nodeset array)
    def js(nodeset='nodes', count=0)
      #do we need to also include an id field inside the object?
      "{name:'"+name+"',"+
      "a:"+nodeset+"["+@a.js_k+"],b:"+nodeset+"["+@b.js_k+"]"+","+
      "reltype:"+@rel_type.to_s+","+
      "n:"+count.to_s+"}"
      #can add more fields as needed
    end
    
    #gets a unique key for the edge (A-B) => (AiehB) / (AdB)
    def js_k
      conn = @rel_type & INCREASES != 0 ? 'i' : 'd'
      conn += 'e'*[(@rel_type&EXPANDABLE),1].min + 'h'*[(@rel_type&HIGHLIGHTED),1].min
      "'"+@a.js_k+conn+@b.js_k+"'"
    end
  end

######## END SUBCLASS DEFINITIONS #########  

  attr_accessor :nodes, :edges, :adjacency, :width, :height
  
  def initialize(args)
    @width, @height = args[:width], args[:height]
    
    puts args
    
    @nodes = args[:nodes]
    @edges = args[:edges]
        
    reset_graph(args, @width, @height) if @nodes.nil? #currently resets to random

    #normally will init to pull out the nodes we want to see... or something. Will need to figure out how that works
  end


  # method fetches the Issues and Relationships from the database, dependent on the arguments
  # args is probably a hash of something
  # WORK IN PROGRESS
  def get_data(args)
    @nodes = Array.new()
    @edges = Array.new()

    
    ### TOP 40 ###
    #get 40 most recent issues
    issues = Issue.order("updated_at DESC").limit(40)
    puts issues    
    
    
    subquerylist = Issue.order("updated_at DESC").limit(40).select("issues.id").map {|i| i.id}
    relationships = Relationship.where("relationships.issue_id IN (?)", subquerylist) #This works (needs other half)

    #get all relationships between those nodes
    #relationships = Relationship.find()
    #query = User.where("users.account_id IN (#{subquery.to_sql})") #this seems messy; may just use same command



    #now that we have our issues and relationships; convert them!
    issues.each {|issue| @nodes.push(Node.new(issue.id, issue.title, issue.wiki_url))}
    relationships.each do |rel| 
      node_a = #<<get node a>>
      node_b = #<<get node b>>
      type = #get type/numcount/something
      @edges.push(Edge.new(rel.id, node_a, node_b    ))
    end
    

    ## ALT: get 40 Issues that have the most relationships
    ## Issue.find().relationships.length + Issue.find().inverse_relationships.length

    #With our list of issues, get all the relationships between them (a relationship that has a and b in the list)
    
    
    ### ALT: get 20-30 relationships with the most cites
    ### get the issues that are part of those relationships (unique)
    
    
    #### ALT: do Bill's algorithm for what to get

  end

  

  def random_graph(node_count, edge_ratio)
    puts "edge_ratio=" + edge_ratio.to_s
    @nodes = Array.new(node_count) {|i| Node.new(i, "Node "+i.to_s, "myurl")} #make all the nodes
    @edges = Array.new() #an array to hold edges
    @adjacency = Array.new(node_count) {|i| Array.new(node_count)} #an adjacency matrix of edges (for easy referencing)
    for i in (0...node_count)
      for j in (0...node_count) #edges in both directions
        if(i!=j and rand() < edge_ratio) #make random edges
          #want random number between 1 and 3
          rel_type = (rand()*15).ceil #get a random set of attributes (rel_type) for that edge
          @edges.push(Edge.new(j*node_count+i, @nodes[i], @nodes[j], rel_type))
          @adjacency[i][j] = @edges.last #assuming we only have 1 edge in each direction
        end
      end
    end
  end

  # put the nodes into a circle that will (mostly) fit in the given canvas
  def circle_nodes(width=@width, height=@height, nodeset=@nodes)
    center = Vector[width/2, height/2]
    radius = [width,height].min/2
    nodeset.each_index{|i| nodeset[i].location = Vector[
      center[0] + (radius * Math.cos(2*Math::PI*i/nodeset.length)), 
      center[1] + (radius * Math.sin(2*Math::PI*i/nodeset.length))]}
  end

  #put the nodes in random locations
  def place_randomly(width=@width, height=@height, nodeset=@nodes)
    for node in nodeset
      node.location = Vector[rand(width), rand(height)]
    end
  end

  def reset_graph(args, width=@width, height=@height)
    random_graph(args[:node_count].to_i, args[:edge_ratio].to_f) #default amount
    place_randomly
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
          nx = [[v.location[0],0].max, width].min #don't let outside of bounds (50px border)
          ny = [[v.location[1],0].max, height].min
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
    until currEnergy < 0.01 or (currEnergy-prevEnergy).abs < 0.0001 or iters > 5000 do #energy threshold?
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
      #puts "end of loop "+iters.to_s+", energy=" + currEnergy.to_s
      iters+=1
    end
    for n in nodeset # convert back to "screen" coordinates (from within 4x4 bounding box, in this case, with 50px border)
      n.location = Vector[((n.location[0]+2)/4.0)*width,((n.location[1]+2)/4.0)*height]
    end    
    puts "springy stopped; energy="+currEnergy.to_s+", iters="+(iters-1).to_s
  end

  # adapted from http://code.google.com/p/foograph/source/browse/trunk/lib/vlayouts/kamadakawai.js?r=64
  # this seems to work best for connected graphs; may need to do something to adjust that 
  def kamada_kawai(width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjacency=@adjacency)
    #calculate shortest path distance (Floyd-Warshall); could be sped up using Johnson's Algorithm (if needed)
    @path_distance = Array.new(nodeset.length) {|i| Array.new(nodeset.length) {|j| if !adjacency[i][j].nil? then 1.0 else 0.0 end}}
    for k in (0...nodeset.length)
      for i in (0...nodeset.length)
        for j in (0...nodeset.length)
          # if not same node AND subpaths exist AND (not yet ij path OR ikj path is shorter)
          if (i!=j) and (@path_distance[i][k]*@path_distance[k][j] != 0) and 
            (@path_distance[i][j]==0 or @path_distance[i][k]+@path_distance[k][j] < @path_distance[i][j])
            @path_distance[i][j] = @path_distance[i][k]+@path_distance[k][j]
          end
        end
      end
    end
    
    k = 1.0 #spring constant
    tolerance = 0.001 #epsilon for energy
    l0 = [width,height].min/@path_distance.max.max
    ideal_length = @path_distance.map {|i| i.map {|j| l0*j}}
    spring_strength = @path_distance.map {|i| i.map {|j| if j!=0.0 then k/(j*j) else 0 end}} #0 if undefined
    
    # puts compute_partial_derivatives(1, nodeset, spring_strength, ideal_length) #test call

    delta_p = p = 0
    partial_derivatives = Array.new(nodeset.length)
    partial_derivatives.each_index do |i|
      deriv = compute_partial_derivatives(i, nodeset, spring_strength, ideal_length)
      partial_derivatives[i] = deriv
      delta = Math.sqrt(deriv[0]*deriv[0]+deriv[1]*deriv[1])
      p, delta_p = i, delta if delta > delta_p
    end
    
    last_energy = 1.0/0  
    begin #computing movement based on a particular node p
      p_partials = Array.new(nodeset.length).each_index.map {|i| 
        compute_partial_derivative(i, p, nodeset, spring_strength, ideal_length)}

      last_local_energy = 1.0/0
      begin
        # compute jacobian; copied code basically
        dE_dx_dx = dE_dx_dy = dE_dy_dx = dE_dy_dy = 0
        nodeset.each_index do |i|
          if i!=p
            dx = nodeset[p].location[0] - nodeset[i].location[0]
            dy = nodeset[p].location[1] - nodeset[i].location[1]
            dist = Math.sqrt(dx*dx+dy*dy)
            dist_cubed = dist**3
            k_mi = spring_strength[p][i]
            l_mi = ideal_length[p][i]
            dE_dx_dx += k_mi * (1 - (l_mi * dy * dy) / dist_cubed)
            dE_dx_dy += k_mi * l_mi * dy * dx / dist_cubed
            dE_dy_dx += k_mi * l_mi * dy * dx / dist_cubed
            dE_dy_dy += k_mi * (1 - (l_mi * dx * dx) / dist_cubed)
          end
        end
        
        # calculate dv (amount we should move)
        dE_dx = partial_derivatives[p][0]
        dE_dy = partial_derivatives[p][1]
        dv = Vector[(dE_dx_dy * dE_dy - dE_dy_dy * dE_dx) / (dE_dx_dx * dE_dy_dy - dE_dx_dy * dE_dy_dx),
                       (dE_dx_dx * dE_dy - dE_dy_dx * dE_dx) / (dE_dy_dx * dE_dx_dy - dE_dx_dx * dE_dy_dy)]

        # move vertex
        nodeset[p].location += dv
        
        # recompute partial derivates and delta_p based on new location
        deriv = compute_partial_derivatives(p, nodeset, spring_strength, ideal_length)
        partial_derivatives[p] = deriv
        delta_p = Math.sqrt(deriv[0]*deriv[0]+deriv[1]*deriv[1])

        #check local energy if we should be done--I feel like this could be done with a cleaner conditional
        #repeat until delta is 0 or energy change falls bellow tolerance    
        local_done = false
        if last_local_energy == 1.0/0 #round 1
          local_done = (delta_p == 0)
        else
          local_done = (delta_p == 0) || ((last_local_energy - delta_p)/last_local_energy < tolerance)
        end
        last_local_energy = delta_p #in either case, set our local energy to the last change
        #puts "local energy="+last_local_energy.to_s
      end while !local_done #local energy is still too high
      
      #update partial derivatives and select new p
      old_p = p
      nodeset.each_index do |i|
        old_deriv_p = p_partials[i]
        old_p_partial = compute_partial_derivative(i,old_p, nodeset, spring_strength, ideal_length) #don't we have this already?
        deriv = partial_derivatives[i]
        deriv[0] += old_p_partial[0] - old_deriv_p[0]
        deriv[1] += old_p_partial[1] - old_deriv_p[1]
        partial_derivatives[i] = deriv
        
        delta = Math.sqrt(deriv[0]*deriv[0]+deriv[1]*deriv[1])
        if delta > delta_p
          p = i
          delta_p = delta
        end
      end

      #calc global energy to see if we're done
      #repeat until delta is 0 or energy change falls bellow tolerance 
      global_done = false
      if last_energy != 1.0/0 #make sure we have a value to divide
        global_done = (delta_p == 0) || ((last_energy - delta_p).abs/last_energy < tolerance)
      end
      last_energy = delta_p
      puts "global energy="+last_energy.to_s
    end while !global_done #global energy is still too high
    puts "end of kamada"
  end

  #compute partial derivatives for given nodes (for kmada_kawai)
  #compute contribution of vertex index n to the first partial derivates (dE/dx_m, de/dy_m) (for vertex index m)
  def compute_partial_derivative(m, n, nodeset, spring, ideal)
    if m != n
      dx = nodeset[m].location[0] - nodeset[n].location[0]
      dy = nodeset[m].location[1] - nodeset[n].location[1]
      dist = Math.sqrt(dx*dx+dy*dy)
      result = [spring[m][n]*(dx - ideal[m][n]*dx/dist), spring[m][n]*(dy - ideal[m][n]*dy/dist)]
      #I have almost no way to debug this, since I'm not quite sure of the math
    else
      result = [0.0, 0.0]
    end
  end
  
  #compute partial derivatives for given nodes (for kmada_kawai)
  #compute partial derivatives dE/dx_m and dE/dy_m for node index m
  def compute_partial_derivatives(m, nodeset, spring, ideal)
    result = [0.0, 0.0]
    nodeset.each_index do |n| #so basically it sums up the partial_derivatives?
      deriv = compute_partial_derivative(m, n, nodeset, spring, ideal)
      result[0] += deriv[0]
      result[1] += deriv[1]
    end
    return result
  end    

  #squeezes the graph to fit inside the window (without border), then centers the nodes within the graph
  def normalize_graph(width=@width, height=@height, nodeset=@nodes)
    puts "normalizing graph"
    center = [width/2, height/2]
    far_x = nodeset.max_by{|n| (n.location[0]-center[0]).abs}.location[0] #node with max x
    far_y = nodeset.max_by{|n| (n.location[1]-center[1]).abs}.location[1] #node with max y
    # scale = [[center[0]/(far_x-center[0]).abs, 1.0].min, #if only shrink to fit, not stretch to fill
    #          [center[1]/(far_y-center[1]).abs, 1.0].min]
    scale = [center[0]/(far_x-center[0]).abs, #currently stretches to fill
             center[1]/(far_y-center[1]).abs]
    nodeset.each {|n| n.location = Vector[scale[0]*(n.location[0]-center[0])+center[0],       
                                          scale[1]*(n.location[1]-center[1])+center[1]]}

    max_x = nodeset.max_by{|n| n.location[0]}.location[0]
    max_y = nodeset.max_by{|n| n.location[1]}.location[1]
    min_x = nodeset.min_by{|n| n.location[0]}.location[0]
    min_y = nodeset.min_by{|n| n.location[1]}.location[1]
    center_offset = Vector[(max_x+min_x-width)/2, (max_y+min_y-height)/2] #center of the nodes - desired center
    nodeset.each {|n| n.location = n.location-center_offset}
  end
  
  def remove_edges(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    edgeset.clear #clear the edges for testing
  end

  def force_layout(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    fruchterman_reingold #can specify particular layouts here if we wanted...
  end


end
