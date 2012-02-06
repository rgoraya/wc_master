require 'matrix'

class Mapvisualization #< ActiveRecord::Base
  # include ActiveModel::Validations #do I need any of this?
  # include ActiveModel::Conversion
  # extend ActiveModel::Naming

######## BEGIN SUBCLASS DEFINITIONS #########
  ## Data structures for easier use 
  class Node < Object
    include	ActionView::Helpers::JavaScriptHelper #for javascript escaping

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
      @id.to_s + ": "+@location.to_s+" ("+@name.to_s + ")"
    end

    #returns a javascript version of the object
    def js(offset=0)
      "{id:"+@id.to_s+","+
      "name:'"+escape_javascript(@name)+"',"+
      "x:"+(@location[0]+offset).to_s+",y:"+(@location[1]+offset).to_s+","+
      "url:'"+escape_javascript(@url)+"'}"
      #can add more fields as needed
    end

    #returns a unique javascript key for the node object
    def js_k
      @id.to_s
    end
      
  end  

  class Edge < Object
    attr_accessor :id, :a, :b, :rel_type
    include	ActionView::Helpers::JavaScriptHelper #for javascript escaping

    ## IF these change, remember to alter in javascript!
    DECREASES = 0
    INCREASES = 1 #constants for relationship type
    SUPERSET = 4
    EXPANDABLE = 8
    HIGHLIGHTED = 16
    ##rel_type nil means increases, 'I' means inhibitor (decreases), 'H' means A-superset-B
    RELTYPE_TO_BITMASK = {nil=>INCREASES, 'I'=>DECREASES, 'H'=>SUPERSET}

    def initialize(id, a, b, rel_type=1)
      @id = id #needed?
      @a = a #reference to the node object (as opposed to just an index)
      @b = b
      @rel_type = rel_type  #specified edge.reltype
    end

    def to_s
      conn = @rel_type & INCREASES != 0 ? 'increases' : (@rel_type & SUPERSET == 0 ? 'decreases' : 'is type of')
      "Edge "+@id.to_s+": "+@a.to_s+" "+conn+" "+@b.to_s
    end

    def name
      conn = @rel_type & INCREASES != 0 ? 'increases' : (@rel_type & SUPERSET == 0 ? 'decreases' : 'is type of')
      @a.name+" "+conn+" "+@b.name
    end

    #returns a javascript version of the object 
    #nodeset is the name of the js node array (default to "nodes"), (a and b are references into the nodeset array)
    def js(nodeset='nodes', count=0)
      #do we need to also include an id field inside the object?
      "{name:'"+escape_javascript(name)+"',"+
      "a:"+nodeset+"["+@a.js_k+"],b:"+nodeset+"["+@b.js_k+"]"+","+
      "reltype:"+@rel_type.to_s+","+
      "n:"+count.to_s+"}"
      #can add more fields as needed
    end
    
    #gets a unique key for the edge (A-B) => (AiehB) / (AdB) / (AsB), etc
    def js_k
      conn = @rel_type & INCREASES != 0 ? 'i' : (@rel_type & SUPERSET == 0 ? 'd' : 's')
      conn += 'e'*[(@rel_type&EXPANDABLE),1].min + 'h'*[(@rel_type&HIGHLIGHTED),1].min
      "'"+@a.js_k+conn+@b.js_k+"'"
    end
  end

######## END SUBCLASS DEFINITIONS #########  

  attr_accessor :nodes, :edges, :adjacency, :width, :height
  
  def initialize(args)    
    #puts args
    @width, @height = args[:width], args[:height]        
    @nodes = args[:nodes]
    @edges = args[:edges]
    @adjacency = args[:adjancecy] || Hash.new(0)
           
    graph_from_data(nil)
    #reset_graph(args, @width, @height) if @nodes.nil? #currently resets to random IF NOT DEFINED
    place_randomly
  end


  # method fetches the Issues and Relationships from the database, dependent on the arguments, and constructs graph
  # args is probably a hash of something
  # WORK IN PROGRESS
  def graph_from_data(args)
    @nodes = Hash.new()
    @edges = Array.new()
    @adjacency = Hash.new(0)

    # if args[:query == 'Top40']
    
    ### TOP 40 ###
    #get 40 most recent issues
    issues = Issue.select("id,title,wiki_url").order("updated_at DESC").limit(50)
    #get all relationships between those nodes
    subquery_list = Issue.select("issues.id").order("updated_at DESC").limit(50).map {|i| i.id}
    relationships = Relationship.select("id,cause_id,issue_id,relationship_type").where("relationships.issue_id IN (?) AND relationships.cause_id IN (?)", subquery_list, subquery_list)


    #now that we have our issues and relationships; convert them!    
    issues.each {|issue| @nodes[issue.id] = (Node.new(issue.id, issue.title, issue.wiki_url))}
    relationships.each do |rel| 
      node_a = @nodes[rel.cause_id] #note these are the opposite of what I expected
      node_b = @nodes[rel.issue_id]      
      type = Edge::RELTYPE_TO_BITMASK[rel.relationship_type]
      @edges.push(Edge.new(rel.id, node_a, node_b, type))
      @adjacency[ [node_a.id, node_b.id] ] += 1 #count the edges between those nodes
    end
    puts @adjacency
    

    ## ALT: get 40 Issues that have the most relationships
    ## Issue.find().relationships.length + Issue.find().inverse_relationships.length

    #With our list of issues, get all the relationships between them (a relationship that has a and b in the list)
    
    
    ### ALT: get 20-30 relationships with the most cites
    ### get the issues that are part of those relationships (unique)
    
    
    #### ALT: do Bill's algorithm for what to get

  end

  

  def random_graph(node_count, edge_ratio)
    @nodes = Hash.new()
    @edges = Array.new()
    @adjacency = Hash.new(0)

    (1..node_count).each {|i| @nodes[i] = Node.new(i, "Node "+i.to_s, "myurl")} #make random nodes

    for i in (1..node_count)
      for j in (1..node_count) #edges in both directions, chance of 1 each way
        if(i!=j and rand() < edge_ratio) #make random edges
          #want random number between 1 and 3
          rel_type = (rand()*15).ceil #get a random set of attributes (rel_type) for that edge
          @edges.push(Edge.new(j*node_count+i, @nodes[i], @nodes[j], rel_type))
          @adjacency[[i,j]] += 1 #count the edge
        end
      end
    end
  end

  # put the nodes into a circle that will (mostly) fit in the given canvas
  def circle_nodes(width=@width, height=@height, nodeset=@nodes)
    center = Vector[width/2, height/2]
    radius = [width,height].min/2
    nodeset.each_with_index{|(key, node), i| nodeset[key].location = Vector[
      center[0] + (radius * Math.cos(2*Math::PI*i/nodeset.length)), 
      center[1] + (radius * Math.sin(2*Math::PI*i/nodeset.length))]}
  end

  #put the nodes in random locations
  def place_randomly(width=@width, height=@height, nodeset=@nodes)
    nodeset.each_value do |node|
      node.location = Vector[rand(width), rand(height)]
    end
  end

  def reset_graph(args, width=@width, height=@height)
    random_graph(args[:node_count].to_i, args[:edge_ratio].to_f) #default amount
    place_randomly
  end

  # algorithm from fruchterman_reingold via Kobourov 2004
  def fruchterman_reingold(width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjacency=@adjacency)
    iterations = 500
    area = width*height
    k = nodeset.length > 0 ? Math.sqrt(area/nodeset.length) : 1 #multiply this by .75 to slow it down?
    k2 = k**2
    temperature = width/10
    for i in (1..iterations) do
      nodeset.each_value do |v| #calc repulsive forces
        v.d = Vector[0.0,0.0]
        nodeset.each_value do |u|
          if u!=v
            dist = v.location - u.location
            distlen = dist.r.to_f
            v.d += distlen != 0.0 ? (dist/distlen)*k2/distlen : Vector[0.0,0.0]
          end
        end
      end
      for e in edgeset do #calc attractive forces
        #only changes 1/conn (assuming 1 edge each direction)
        if e.a.id < e.b.id or adjacency[[e.a.id,e.b.id]]+adjacency[[e.b.id,e.a.id]] < 2
          dist = e.a.location - e.b.location
          distlen = dist.r.to_f
          fa = distlen**2/k
          e.a.d -= (dist/distlen)*fa
          e.b.d += (dist/distlen)*fa
        end
      end
      #puts nodeset
      nodeset.each_value do |v| #move nodes
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
  def springy(width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjancency=@adjacency)
    puts "springy called"
    nodeset.each_value do |n|
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
      for k1,n1 in nodeset
        for k2,n2 in nodeset
          if k1 != k2
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
        #only changes 1/conn (assuming 1 edge each direction)
        if e.a.id < e.b.id or adjacency[[e.a.id,e.b.id]]+adjacency[[e.b.id,e.a.id]] < 2
          #puts "applying hooke's law to "+e.to_s
          d = e.b.location - e.a.location
          displacement = 1.0 - d.r #spring "length" at rest?? - magnitude... either 0 or 1 or ?
          direction = d/d.r #normalized
          e.a.a += direction*(stiffness*displacement*-0.5)/1.0 #divide by the "mass" (currently 1)
          e.b.a += direction*(stiffness*displacement*0.5)/1.0
        end
      end

      #nodeset.each {|k,n| puts n.to_s + " accel: "+ n.a.to_s } #seems large... but maybe because of how 

      nodeset.each_value do |n| #finish moving nodes/etc
        n.a += (n.location*-1)*(repulsion/50.0)/1.0 #attract to center
        #puts n.to_s + " accel: "+ n.a.to_s
        n.d += n.a*timestep*damping #update velocity
        #puts n.to_s + " veloc: "+ n.d.to_s
        n.a = Vector[0.0,0.0] #reset acceleration
        n.location += n.d*timestep #update position        
        #puts n.to_s + " loc: "+ n.location.to_s
      end

      scale = Vector[ 2.0/[nodeset.max_by{|k,n| n.location[0].abs}[1].location[0].abs,2.0].max , 
                      2.0/[nodeset.max_by{|k,n| n.location[1].abs}[1].location[1].abs,2.0].max ] #biggest coords
      currEnergy = 0.0
      nodeset.each_value do |n|
        n.location = Vector[n.location[0]*scale[0], n.location[1]*scale[1]] ##rescale to stay within bounds!
        n.d = Vector[n.d[0]*scale[0], n.d[1]*scale[1]]
        # puts n.to_s + " loc: "+ n.location.to_s
        currEnergy += 0.5*1.0*n.d.r**2 #calculate total energy; 1.0=mass
      end
            
      # calc delta energy, and use that for stopping?
      puts "end of loop "+iters.to_s+", energy=" + currEnergy.to_s if iters % 50 == 0
      iters+=1
    end
    for k,n in nodeset # convert back to "screen" coordinates (from within 4x4 bounding box)
      n.location = Vector[((n.location[0]+2)/4.0)*width,((n.location[1]+2)/4.0)*height]
    end
    puts "springy stopped; energy="+currEnergy.to_s+", iters="+(iters-1).to_s
  end

  # adapted from http://code.google.com/p/foograph/source/browse/trunk/lib/vlayouts/kamadakawai.js?r=64
  # this seems to work best for connected graphs; may need to do something to adjust that 
  def kamada_kawai(width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjacency=@adjacency)
    #calculate shortest path distance (Floyd-Warshall); could be sped up using Johnson's Algorithm (if needed)
    @path_distance = Hash.new(0)
    edgeset.each {|e| @path_distance[[e.a.id,e.b.id]] = @path_distance[[e.b.id,e.a.id]] = 1} #fill with L1 dist (non-directional)
    for k,nk in nodeset
      for i,ni in nodeset
        for j,nj in nodeset
          # if not same node AND subpaths exist AND (not yet ij path OR ikj path is shorter)
          if (i!=j) and (@path_distance[[i,k]]*@path_distance[[k,j]] != 0) and 
            (@path_distance[[i,j]]==0 or @path_distance[[i,k]]+@path_distance[[k,j]] < @path_distance[[i,j]])
            @path_distance[[i,j]] = @path_distance[[i,k]]+@path_distance[[k,j]]
          end
        end
      end
    end
    
    k = 1.0 #spring constant
    tolerance = 0.001 #epsilon for energy
    l0 = [width,height].min/@path_distance.values.max #optimal average length
    ideal_length = Hash[@path_distance.map {|key,val| [key,l0*val]}]
    ideal_length.default = 0
    spring_strength = Hash[@path_distance.map {|key,val| [key,k/(val*val)]}] #can be undefined? v!=0 ? k/(v*v) : 0
    spring_strength.default = 0
    
    #puts compute_partial_derivatives(2335, nodeset, spring_strength, ideal_length) #test call
    
    delta_p = p = 0
    partial_derivatives = Hash.new(0)#Array.new(nodeset.length)
    nodeset.each_key do |i| #go through every person; computer partial deriv affect on them
      deriv = compute_partial_derivatives(i, nodeset, spring_strength, ideal_length)
      partial_derivatives[i] = deriv
      delta = Math.sqrt(deriv[0]*deriv[0]+deriv[1]*deriv[1])
      p, delta_p = i, delta if delta > delta_p
    end
            
    last_energy = 1.0/0  
    begin #computing movement based on a particular node p

      
      #this is an array where each index points to the partial deriv for tat index against p
      #so should convert to a hash with 1dim key, that otherwise works the same way!
      p_partials = Hash.new(0)
      nodeset.each_key {|i| p_partials[i] = compute_partial_derivative(i, p, nodeset, spring_strength, ideal_length)}

      last_local_energy = 1.0/0
      begin
        
        # compute jacobian; copied code basically
        dE_dx_dx = dE_dx_dy = dE_dy_dx = dE_dy_dy = 0
        nodeset.each_key do |i|
          if i!=p
            dx = nodeset[p].location[0] - nodeset[i].location[0]
            dy = nodeset[p].location[1] - nodeset[i].location[1]
            dist = Math.sqrt(dx*dx+dy*dy)
            dist_cubed = dist**3
            k_mi = spring_strength[[p,i]]
            l_mi = ideal_length[[p,i]]
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
      nodeset.each_key do |i|
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
      result = [spring[[m,n]]*(dx - ideal[[m,n]]*dx/dist), spring[[m,n]]*(dy - ideal[[m,n]]*dy/dist)]
      #I have almost no way to debug this, since I'm not quite sure of the math
    else
      result = [0.0, 0.0]
    end
  end
  
  #compute partial derivatives for given nodes (for kmada_kawai)
  #compute partial derivatives dE/dx_m and dE/dy_m for node index m
  def compute_partial_derivatives(m, nodeset, spring, ideal)
    result = [0.0, 0.0]
    nodeset.each_key do |n| #so basically it sums up the partial_derivatives?
      deriv = compute_partial_derivative(m, n, nodeset, spring, ideal)
      result[0] += deriv[0]
      result[1] += deriv[1]
    end
    return result
  end    

  #centers the nodes within the graph, then squeezes the graph to fit inside the window (without border)
  def normalize_graph(width=@width, height=@height, nodeset=@nodes)
    puts "normalizing graph"

    #center the nodes
    max_x = nodeset.max_by{|k,n| n.location[0]}[1].location[0]
    max_y = nodeset.max_by{|k,n| n.location[1]}[1].location[1]
    min_x = nodeset.min_by{|k,n| n.location[0]}[1].location[0]
    min_y = nodeset.min_by{|k,n| n.location[1]}[1].location[1]
    center_offset = Vector[(max_x+min_x-width)/2, (max_y+min_y-height)/2] #center of the nodes - desired center
    nodeset.each_value {|n| n.location = n.location-center_offset}

    #scale to fit
    center = [width/2, height/2]
    far_x = nodeset.max_by{|k,n| (n.location[0]-center[0]).abs}[1].location[0] #node with max x
    far_y = nodeset.max_by{|k,n| (n.location[1]-center[1]).abs}[1].location[1] #node with max y
    # scale = [[center[0]/(far_x-center[0]).abs, 1.0].min, #if only shrink to fit, not stretch to fill
    #          [center[1]/(far_y-center[1]).abs, 1.0].min]
    scale = [center[0]/(far_x-center[0]).abs, #currently stretches to fill
             center[1]/(far_y-center[1]).abs]
    nodeset.each_value {|n| n.location = Vector[scale[0]*(n.location[0]-center[0])+center[0],       
                                                scale[1]*(n.location[1]-center[1])+center[1]]}
  end
  
  def remove_edges(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    edgeset.clear #clear the edges for testing
  end

  def force_layout(width=@width, height=@height, nodeset=@nodes, edgeset=@edges)
    fruchterman_reingold #can specify particular layouts here if we wanted...
  end


end
