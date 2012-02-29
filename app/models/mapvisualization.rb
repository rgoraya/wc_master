require 'matrix'

class Mapvisualization #< ActiveRecord::Base
  # include ActiveModel::Validations #do I need any of this?
  # include ActiveModel::Conversion
  # extend ActiveModel::Naming

######## BEGIN SUBCLASS DEFINITIONS #########
  ## Data structures for easier use 
  class Node < Object
    include	ActionView::Helpers::JavaScriptHelper #for javascript escaping

    attr_accessor :id, :name, :url, :location, :static, :highlighted, :d, :a

    def initialize(id, name, url)
      @id = id #db-level index
      @name = name
      @url = url
      @location = Vector[0.0,0.0]
      @static = false #should the node move or not
      @highlighted = false
      @d = Vector[0.0,0.0] #delta variable
      @a = Vector[0.0,0.0] #acceleration variable
    end

    def to_s
      @id.to_s + ": "+@location.to_s+" ("+@name.to_s + ")"
    end
  end  

  class Edge < Object
    attr_accessor :id, :a, :b, :rel_type
    include	ActionView::Helpers::JavaScriptHelper #for javascript escaping

    ##a converter for building the edges; can eventually get moved into the db parser (what Eugenia is doing) ??
    ## where should the bitmask constants be? should I just store rel_type as a string and not deal with it otherwise??
    ##rel_type nil means increases, 'I' means inhibitor (decreases), 'H' means A-superset-B
    RELTYPE_TO_BITMASK = {nil=>MapvisualizationsHelper::INCREASES, 'I'=>MapvisualizationsHelper::DECREASES, 'H'=>MapvisualizationsHelper::SUPERSET}

    def initialize(id, a, b, rel_type=1)
      @id = id #needed?
      @a = a #reference to the node object (as opposed to just an index)
      @b = b
      @rel_type = rel_type  #specified edge.reltype
    end

    def to_s
      "Edge "+@id.to_s+": "+name
    end

    def name
      conn = @rel_type & MapvisualizationsHelper::INCREASES != 0 ? 'increases' : (@rel_type & MapvisualizationsHelper::SUPERSET == 0 ? 'decreases' : 'includes')
      @a.name+" "+conn+" "+@b.name
    end

  end

######## END SUBCLASS DEFINITIONS #########  

  attr_accessor :nodes, :edges, :adjacency, :width, :height, :compact_display, :notice, :graph
  
  BAD_PARAM_ERROR = "Please specify what to visualize!"
  NO_ITEM_ERROR = "The item you requested could not be found"
  
  def initialize(args)    
    #puts args
    @width, @height = args[:width], args[:height]
    @compact_display = false
    @nodes = args[:nodes] || Hash.new()
    @edges = args[:edges] || Array.new()
    @adjacency = args[:adjancecy] || Hash.new(0)

	# Build a Graph of Nodes
	@graph = Graph.new

    puts "===mapvisualization initialize args===" #debugging
    puts args

    handle_params(args[:params],args)
  end

  # picks the right stuff to display/initialize model with based on passed in parameters
  def handle_params(params,args) #passing in args for testing still; can eventually get rid of that
    if params[:q] #do we have a query to use?
      params[:q] = params[:q].downcase

      ### SHOW PARTICULAR ###
      if params[:q] == 'show'
        if params[:i] #show issues
          static = params[:i].split(%r{[,;]}).map(&:to_i).reject{|i|i==0} #get the list of numbers (reject everything else)

          ### EUGENIA ###
          # This is where we build a graph around a particular node or set of nodes (fetched out the param above)
          # This is probably what "get_graph_of_effects" was meant to do, basically fetch the nodes that are 
          # connected to the nodes whose id is in "static" above.
          # We need to set @nodes and @edges in here, before calling the last two lines of this block
          ###

          issues, relationships = build_graph(static,30) #why would this get called later than the default-layout??
      
          convert_activerecords(issues,relationships)
          @nodes.each {|key,node| node.static = 'center' if static.include? key} #makes the "static" variables centered
          default_layout
        
        elsif params[:r] #show relationships
          static_rel_ids = params[:r].split(%r{[,;]}).map(&:to_i).reject{|i|i==0}

          ### EUGENIA ###
          # This is where we build a graph around a particular edge or set of edges (fetched out the param above)
          # This is probably what "get_graph_of_effects" was meant to do, basically fetch the nodes that are 
          # connected to the nodes who are part of the relationships in "static_rel_ids" above.
          # note the cheap "get relationships from nodes" call below before we build the graph exactly as above.
          # We need to set @nodes and @edges in here, before calling the last two lines of this block
          ###

          rels = Relationship.select("cause_id,issue_id").where("relationships.id IN (?)", static_rel_ids) #can we clean this up??
          static = rels.map {|rel| [rel.issue_id, rel.cause_id]}.flatten.uniq

          issues, relationships = build_graph(static,30)

          convert_activerecords(issues,relationships)
          @nodes.each {|key,node| node.static = 'center' if static.include? key} #makes the "static" variables centered
          default_layout          
        else
          @notice = BAD_PARAM_ERROR
        end               

      ### TOP 40 ###
      elsif params[:q] == 'last40'

		# Update graph nodes & edges to include most recent 40 nodes
		limit = 40		
		@graph.get_graph_of_most_recent(limit)
		
		@nodes = @graph.nodes
		@edges = @graph.edges

        ### EUGENIA ###
        # This is where we show the most recent 40 nodes
        # This is where get_graph_of_most_recent would go
        # We need to set @nodes and @edges in here, before calling the last line of this block.
        # This functionality is less important than the above blocks
        ###
        
        #issues = Issue.select("id,title,wiki_url").order("updated_at DESC").limit(limit) #get 40 most recent issues
        #get all relationships between those nodes
        #subquery_list = Issue.select("issues.id").order("updated_at DESC").limit(limit).map {|i| i.id}
        #relationships = Relationship.select("id,cause_id,issue_id,relationship_type").where("relationships.issue_id IN (?) AND relationships.cause_id IN (?)", subquery_list, subquery_list)

        #convert_activerecords(issues,relationships)
        default_layout

      ### TOP RELATIONSHIPS AND THEIR NODES ###
      elsif params[:q] == 'mostcited' 
        ### EUGENIA ###
        # This is where we show the most cited references
        # We probably want a get_graph_of_most_cited method to call
        # We need to set @nodes and @edges in here, before calling the last line of this block.
        # This functionality is less important than the above blocks.
        ###

        limit = 40
        relationships = Relationship.select("id,cause_id,issue_id,relationship_type").order("references_count DESC,updated_at DESC").limit(limit) #get top rated/most recent relationships
        #get all nodes linked by those relationships
        subquery_list = Relationship.select("cause_id, issue_id").order("references_count DESC,updated_at DESC").limit(limit).flat_map {|i| [i.issue_id,i.cause_id]}.uniq.sort #sort here? making multiple array passes...
        issues = Issue.select("id,title,wiki_url").where("issues.id IN (?)", subquery_list)

        convert_activerecords(issues,relationships)
        default_layout

      elsif params[:q] == 'allthethings' ### EVERYTHING. DO NOT CALL THIS ###
        ### EUGENIA ###
        # This is where we show all of the nodes
        # This is where get_graph_of_all would go
        # We need to set @nodes and @edges in here, before calling the last two line of this block.
        ###
        
        issues = Issue.select("id,title,wiki_url")
        relationships = Relationship.select("id,cause_id,issue_id,relationship_type")

        convert_activerecords(issues,relationships)
        @compact_display = true #use compact display
        place_randomly

      ### RANDOM TEST GRAPH ###
      elsif params[:q] == 'test'
        reset_graph(args, @width, @height)
        circle_nodes

        #highlight a few edges (and their nodes) for testing
        # @edges[1].rel_type = @edges[1].rel_type | MapvisualizationsHelper::HIGHLIGHTED
        # @edges[1].a.highlighted = true
        # @edges[1].b.highlighted = true
        # @edges[2].rel_type = @edges[2].rel_type | MapvisualizationsHelper::HIGHLIGHTED
        # @edges[2].a.highlighted = true
        # @edges[2].b.highlighted = true
  
      else #if not specified, default to show something
        @notice = BAD_PARAM_ERROR
      end
    
    ### DEFAULT ###
    else #if no params
      issues, relationships = default_graph
      convert_activerecords(issues,relationships)
      default_layout
    end
  end

  # fetch a default graph if options missing??
  # alternatively, display an error/message somehow??
  def default_graph
    ### EUGENIA ###
    # This is where we get a "default" set of nodes to show, currently defaulting to the first 40 for testing
    # This is where get_graph_of_earliest would go.
    # Note that this method returns a set of activerecords that we then convert in "convert_activerecords()", 
    # but such a functionality need not exist (we can just set @nodes and @edges from here)
    ###

    #default to first 40 (cause they are connected)? or to what?
    limit = 40
    issues = Issue.select("id,title,wiki_url").order("updated_at ASC").limit(limit)
    #get all relationships between those nodes
    subquery_list = Issue.select("issues.id").order("updated_at ASC").limit(limit).map {|i| i.id}
    relationships = Relationship.select("id,cause_id,issue_id,relationship_type").where("relationships.issue_id IN (?) AND relationships.cause_id IN (?)", subquery_list, subquery_list)      
    return [issues,relationships]
  end
  
  # builds a graph centered around a starting set of nodes.
  # starting_nodes is a list of node ids; limit is up to how many things we should get
  def build_graph(starting_nodes, limit)
    ### EUGENIA ###
    # This is the function where we do the equivalent of "get_graph_of_effects" by building up a set of connections to
    # the given starting nodes.
    # Note that this method returns a set of activerecords that we then convert in "convert_activerecords()", 
    # but such a functionality need not exist (we can just set @nodes and @edges from here)
    ###

    ids = Array.new(starting_nodes)
    while ids.length < limit
      new_ids = Relationship.select("issue_id, cause_id").where("(relationships.issue_id IN (?) OR relationships.cause_id IN (?)) AND NOT (relationships.issue_id IN (?) AND relationships.cause_id IN (?))", ids, ids, ids, ids).map {|i| [i.issue_id, i.cause_id]}
      break if new_ids.length == 0
      ids = (ids + new_ids).flatten.uniq
    end
    ids = ids.slice(0,limit-1)
    issues = Issue.select("id,title,wiki_url").where("issues.id IN (?)", ids)
    subquery_list = issues.map {|i| i.id}
    relationships = Relationship.select("id,cause_id,issue_id,relationship_type").where("relationships.issue_id IN (?) AND relationships.cause_id IN (?)", subquery_list, subquery_list)
    [issues, relationships]
  end
  
  #converts activerecord arrays into the instance variables we want to use, separate function so we can do further processing later
  def convert_activerecords(issues,relationships)
    ### EUGENIA ###
    # This is the function where we do convert the active records that we've fetched from the database into 
    # nodes and edges, storing them in @nodes and @edges
    ###

    issues.each {|issue| @nodes[issue.id] = (Node.new(issue.id, issue.title, issue.wiki_url))} if !issues.nil?
    relationships.each do |rel| 
      node_a = @nodes[rel.cause_id] #note these are the opposite of what I expected
      node_b = @nodes[rel.issue_id]      
      type = Edge::RELTYPE_TO_BITMASK[rel.relationship_type]
      @edges.push(Edge.new(rel.id, node_a, node_b, type))
      @adjacency[ [node_a.id, node_b.id] ] += 1 #count the edges between those nodes
    end if !relationships.nil?
  end

  # generates a random graph
  def random_graph(node_count, edge_ratio)
    @nodes = Hash.new()
    @edges = Array.new()
    @adjacency = Hash.new(0)
    (1..node_count).each {|i| @nodes[i] = Node.new(i, "Node "+i.to_s, "myurl")} #make random nodes
    for i in (1..node_count)
      for j in (1..node_count) #edges in both directions, chance of 1 each way
        if(i!=j and rand() < edge_ratio) #make random edges
          rel_type = (rand()*10).ceil #get a random set of attributes (rel_type) for that edge
          @edges.push(Edge.new(j*node_count+i, @nodes[i], @nodes[j], rel_type))
          @adjacency[[i,j]] += 1 #count the edge
        end
      end
    end
  end

  # returns whether anything in this graph is highlighted or not.
  # version in helper currently being used
  def has_highlighted?(edgeset=@edges)
    edgeset.find {|e| e.rel_type & MapvisualizationsHelper::HIGHLIGHTED != 0} != nil
  end

  #places the static nodes at their desired locations
  def set_static_nodes(width=@width, height=@height, nodeset=@nodes)
    nodeset.each_value do |node|
      if node.static == 'center'
        node.location = Vector[width/2,height/2]
      elsif node.static == 'stationary' #just leave at location
      elsif node.static == 'left'
        node.location = Vector[0,height/2]
      elsif node.static == 'right'
        node.location = Vector[0,height/2]
      end
      #can add other handlers if needed
    end
  end

  # the default set of layout commands (hopefully not slow)
  def default_layout()
    if @nodes.length > 0
      set_static_nodes
      static_wheel_nodes
      fruchterman_reingold(100) #fast, little bit of layout for now
      normalize_graph
      #do_kamada_kawai
    else
      @notice = NO_ITEM_ERROR
    end
  end

  # put the nodes into a circle that will fit in the given canvas
  def circle_nodes(width=@width, height=@height, nodeset=@nodes)
    center = Vector[width/2, height/2]
    radius = [width,height].min/2
    nodeset.each_with_index{|(key, node), i| nodeset[key].location = Vector[
      center[0] + (radius * Math.cos(2*Math::PI*i/nodeset.length)), 
      center[1] + (radius * Math.sin(2*Math::PI*i/nodeset.length))] if !nodeset[key].static}
  end

  # puts the nodes in a circle with the static nodes in a smaller, centered circle
  def static_wheel_nodes(width=@width, height=@height, nodeset=@nodes)
    static = Hash.new()
    nonstatic = Hash.new()
    nodeset.each do |key,node| 
      if node.static == 'center'
        static[key] = node
      else
        nonstatic[key] = node 
      end
    end
    
    circle_nodes(width,height,nonstatic) #circle the nonstatics normally

    # this is just the code from circle_nodes, without the "static" check (and swapped circle list). Not worth factoring out
    center = Vector[width/2, height/2]
    radius = (static.length==0 ? 0 : [width,height].min/20)
    static.each_with_index{|(key, node), i| static[key].location = Vector[
      center[0] + (radius * -1*Math.cos(2*Math::PI*i/static.length)), 
      center[1] + (radius * -1*Math.sin(2*Math::PI*i/static.length))]}
  end

  # put the nodes into a grid that will fit in the given canvas
  def grid_nodes(width=@width, height=@height, nodeset=@nodes)
    puts "grid_nodes called"
    num_cols = (Math.sqrt(nodeset.length)*(width/height)).ceil
    num_rows = (nodeset.length/num_cols.to_f).ceil
    col_len = width/num_cols
    row_len = height/num_rows
    nodeset.each_with_index{|(key, node), i| nodeset[key].location = 
      Vector[(0.5 + (i%num_cols))*col_len,(0.5 + (i/num_cols))*row_len] if !nodeset[key].static}
  end

  #put the nodes in random locations
  def place_randomly(width=@width, height=@height, nodeset=@nodes)
    nodeset.each_value do |node|
      node.location = Vector[rand(width), rand(height)] if !node.static
    end
  end

  def reset_graph(args, width=@width, height=@height)
    random_graph(args[:node_count].to_i, args[:edge_ratio].to_f) #default amount
    place_randomly
  end

  # algorithm from fruchterman_reingold via Kobourov 2004
  def fruchterman_reingold(max_iters=100, width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjacency=@adjacency)
    puts "beginning fruchterman_reingold @ "+Time.now.to_s
    iterations = max_iters
    area = width*height
    k = nodeset.length > 0 ? Math.sqrt(area/nodeset.length) : 1 #multiply this by .75 to slow it down?
    k2 = k**2
    temperature = width/10
    for i in (1..iterations) do
      nodeset.each_value do |v| #calc repulsive forces
        if !v.static
          v.d = Vector[0.0,0.0]
          nodeset.each_value do |u|
            if u!=v
              dist = v.location - u.location
              distlen = dist.r.to_f
              v.d += distlen != 0.0 ? (dist/distlen)*k2/distlen : Vector[0.0,0.0]
            end
          end
        end
      end
      for e in edgeset do #calc attractive forces
        #only changes 1/conn (assuming 1 edge each direction)
        if e.a.id < e.b.id or adjacency[[e.a.id,e.b.id]]+adjacency[[e.b.id,e.a.id]] < 2
          dist = e.a.location - e.b.location
          distlen = dist.r.to_f
          fa = distlen**2/k
          e.a.d -= (dist/distlen)*fa if !e.a.static
          e.b.d += (dist/distlen)*fa if !e.b.static
        end
      end
      #puts nodeset
      nodeset.each_value do |v| #move nodes
        #added in attraction to center
        if !v.static
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
      end
      temperature *= (1 - i/iterations.to_f) #cooling function from http://goo.gl/xcbXR
      puts "finished iter "+i.to_s+" @ "+Time.now.to_s
    end
    puts "finished fruchterman_reingold @ "+Time.now.to_s
  end

  # adapted from https://github.com/dhotson/springy/blob/master/springy.js
  def springy(width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjancency=@adjacency)
    puts "beginning springy @ "+Time.now.to_s
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
            n1.a += direction*(repulsion/(distance*distance*0.5))/1.0 if !n1.static#divide by "mass" (currently 1)
            n2.a += direction*(repulsion/(distance*distance*-0.5))/1.0 if !n2.static#divide by "mass" (currently 1)          
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
          e.a.a += direction*(stiffness*displacement*-0.5)/1.0 if !e.a.static #divide by the "mass" (currently 1)
          e.b.a += direction*(stiffness*displacement*0.5)/1.0 if !e.b.static
        end
      end

      #nodeset.each {|k,n| puts n.to_s + " accel: "+ n.a.to_s } #seems large... but maybe because of how 

      nodeset.each_value do |n| #finish moving nodes/etc
        if !n.static
          n.a += (n.location*-1)*(repulsion/50.0)/1.0 #attract to center
          #puts n.to_s + " accel: "+ n.a.to_s
          n.d += n.a*timestep*damping #update velocity
          #puts n.to_s + " veloc: "+ n.d.to_s
          n.a = Vector[0.0,0.0] #reset acceleration
          n.location += n.d*timestep #update position        
          #puts n.to_s + " loc: "+ n.location.to_s
        end
      end

      scale = Vector[ 2.0/[nodeset.max_by{|k,n| n.location[0].abs}[1].location[0].abs,2.0].max , 
                      2.0/[nodeset.max_by{|k,n| n.location[1].abs}[1].location[1].abs,2.0].max ] #biggest coords
      currEnergy = 0.0
      nodeset.each_value do |n|
        if !n.static
          n.location = Vector[n.location[0]*scale[0], n.location[1]*scale[1]]##rescale to stay within bounds!
          n.d = Vector[n.d[0]*scale[0], n.d[1]*scale[1]]
          # puts n.to_s + " loc: "+ n.location.to_s
          currEnergy += 0.5*1.0*n.d.r**2 #calculate total energy; 1.0=mass
        end
      end
            
      # calc delta energy, and use that for stopping?
      #puts "end of loop "+iters.to_s+", energy=" + currEnergy.to_s if iters % 50 == 0
      iters+=1
    end
    for k,n in nodeset # convert back to "screen" coordinates (from within 4x4 bounding box)
      n.location = Vector[((n.location[0]+2)/4.0)*width,((n.location[1]+2)/4.0)*height]
    end
    puts "springy stopped; energy="+currEnergy.to_s+", iters="+(iters-1).to_s
    puts "finished springy @ "+Time.now.to_s
  end

  # adapted from http://code.google.com/p/foograph/source/browse/trunk/lib/vlayouts/kamadakawai.js?r=64
  # this seems to work best for connected graphs; may need to do something to adjust that 
  def kamada_kawai(width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjacency=@adjacency)
    puts "beginning kamada_kawai @ "+Time.now.to_s

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
      #puts k.to_s + " "+Time.now.to_s
    end
    
    puts "(found path distances) @ "+Time.now.to_s
    
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
      if !nodeset[i].static
        deriv = compute_partial_derivatives(i, nodeset, spring_strength, ideal_length)
        partial_derivatives[i] = deriv
        delta = Math.sqrt(deriv[0]*deriv[0]+deriv[1]*deriv[1])
        p, delta_p = i, delta if delta > delta_p
      end
    end
            
    last_energy = 1.0/0  
    begin #computing movement based on a particular node p

      p_partials = Hash.new(0)
      nodeset.each_key {|i| p_partials[i] = compute_partial_derivative(i, p, nodeset, spring_strength, ideal_length)}

      last_local_energy = 1.0/0
      begin
        if !nodeset[p].static
          # compute jacobian; copied code basically
          dE_dx_dx = dE_dx_dy = dE_dy_dx = dE_dy_dy = 0.0
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

          # if for some reason our dv ends up being infinite (divide by 0), just set to 0??
          # and why in gods name is assignment a private function?! And why doesn't rails say so?!
          dv = Vector[0.0,dv[1]] if dv[0].infinite?
          dv = Vector[dv[0],0.0] if dv[1].infinite?

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
        end
      end while !local_done #local energy is still too high
      
      #update partial derivatives and select new p
      old_p = p
      nodeset.each_key do |i|
        if !nodeset[i].static
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
      end

      #calc global energy to see if we're done
      #repeat until delta is 0 or energy change falls bellow tolerance 
      global_done = false
      if last_energy != 1.0/0 #make sure we have a value to divide
        global_done = (delta_p == 0) || ((last_energy - delta_p).abs/last_energy < tolerance)
      end
      last_energy = delta_p
      #puts "global energy="+last_energy.to_s
    end while !global_done #global energy is still too high
    puts "finished kamada_kawai @ "+Time.now.to_s
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

  #run kamada then normalize (to save button presses :p)
  def do_kamada_kawai
    kamada_kawai
    normalize_graph
  end

  #centers the nodes within the graph, then squeezes the graph to fit inside the window (without border)
  def normalize_graph(width=@width, height=@height, nodeset=@nodes)
    puts "normalizing graph"
    
    if nodeset.length > 0 #to handle empty graphs; could also do it in default layout (else display message)
      #center the nodes
      max_x = nodeset.max_by{|k,n| n.location[0]}[1].location[0]
      max_y = nodeset.max_by{|k,n| n.location[1]}[1].location[1]
      min_x = nodeset.min_by{|k,n| n.location[0]}[1].location[0]
      min_y = nodeset.min_by{|k,n| n.location[1]}[1].location[1]
      center_offset = Vector[(max_x+min_x-width)/2, (max_y+min_y-height)/2] #center of the nodes - desired center
      nodeset.each_value {|n| n.location = n.location-center_offset if !n.static}

      #scale to fit
      center = [width/2, height/2]
      far_x = nodeset.max_by{|k,n| (n.location[0]-center[0]).abs}[1].location[0] #node with max x
      far_y = nodeset.max_by{|k,n| (n.location[1]-center[1]).abs}[1].location[1] #node with max y
      # scale = [[center[0]/(far_x-center[0]).abs, 1.0].min, #if only shrink to fit, not stretch to fill
      #          [center[1]/(far_y-center[1]).abs, 1.0].min]
      scale = [center[0]/(far_x-center[0]).abs, #currently stretches to fill
               center[1]/(far_y-center[1]).abs]      
      scale[0] = 1 if scale[0] == 1.0/0 #if we don't need to stretch, then don't!
      scale[1] = 1 if scale[1] == 1.0/0

      nodeset.each_value {|n| n.location = Vector[scale[0]*(n.location[0]-center[0])+center[0],       
                                                  scale[1]*(n.location[1]-center[1])+center[1]] if !n.static}
    end
  end

end
