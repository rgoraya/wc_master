require 'matrix'

class Mapvisualization #< ActiveRecord::Base
  # include ActiveModel::Validations #do I need any of this?
  # include ActiveModel::Conversion
  # extend ActiveModel::Naming

  attr_accessor :nodes, :edges, :adjacency, :width, :height, :compact_display, :notice, :graph, :cause_issue, :effect_issue
  
  BAD_PARAM_ERROR = "Please specify what to visualize!"
  NO_ITEM_ERROR = "The item you requested could not be found"
  
  def initialize(args)    
    #puts args
    @width, @height = args[:width], args[:height]
    @compact_display = false
    @nodes = args[:nodes] || Hash.new()
    @edges = args[:edges] || Hash.new()
    @adjacency = args[:adjacency] || Hash.new(0)

  	# Build a Graph of Nodes
  	@graph = Graph.new

    #variables to tell the controller (and the non-vis parts of the view) what we're showing
    @cause_issue = nil
    @effect_issue = nil
   
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

    		  @graph.get_graph_of_issue_neighbors(static, limit=20)
				  @graph.get_all_pairs_paths_distances

    		  # Temporary
        	@nodes = @graph.nodes
        	@edges = @graph.edges

    		  # Make static variables centered
    		  @nodes.each {|key,node| node.static = 'center' if static.include? key}
    		  
          target_layout(static)
  		    #default_layout

          @cause_issue = Issue.find(static.first) unless static.first.nil?
                  
        elsif params[:r] #show relationships
          static_rel_ids = params[:r].split(%r{[,;]}).map(&:to_i).reject{|i|i==0}
          ### WHAT IS THE CAUSE_ID AND EFFECT_ID?

    		  # Generate graph of these relationships, their connected issues, and issues connected to those.
    		  @graph.get_graph_of_relationship_endpoints(static_rel_ids,limit=20)
			    @graph.get_all_pairs_paths_distances

    		  # Make endpoints of core relationships ("static") centered on the graph
    		  @graph.nodes.each {|key,node| node.static = 'center' if @graph.sources.include? key}

    		  # Temporary
    		  @nodes = @graph.nodes
    		  @edges = @graph.edges

          #target_layout(static_rel_ids) ##needs to have the list of nodes in the static_rel in order to do this
  		    default_layout

        else
          @notice = BAD_PARAM_ERROR
        end               

  	  ### PATH GENERATION ###
  	  elsif params[:q] == 'path'
    		# Basic source to destination graph
    		if params[:from] and params[:to]  
    			# PLACEHOLDER for format-checking / conversion
          
    			from_id = params[:from].to_i
    			to_id = params[:to].to_i

    			# This could probably be a bit more graceful
    			check = @graph.check_path_src_dest(from_id, to_id)
    			if check == 1
				
    				# Try to find a path between source and destination in graph
    				path_found = @graph.get_graph_of_path(from_id, to_id)
    				#@notice = path_found.to_s

    				puts "paths found", path_found

    				@graph.nodes[from_id].static = 'left'
    				@graph.nodes[to_id].static = 'right'

    				# Temporary
    				@nodes = @graph.nodes
    				@edges = @graph.edges

    				#@compact_display = true
    				#place_randomly		
    				default_layout

            @cause_issue = Issue.find(from_id) unless from_id.nil?
            @effect_issue = Issue.find(to_id) unless to_id.nil?
			
    			elsif check == 0
    				# Degrade to all paths from a given source
    				@notice = "Path destination does not exist. Showing paths from source."

    			else
    				@notice = "Invalid path source or destination. Please try again."
    			end
        else
          @notice = BAD_PARAM_ERROR
        end

      ### EVERYTHING. DO NOT CALL THIS ###
      elsif params[:q] == 'allthethings'
    		# Generate a graph of all nodes
    		@graph.get_graph_of_all

  			# DO NOT USE THIS METHOD HERE unless you want to cry alone in the night forever
  			# foreverAlone
  			# @graph.get_all_pairs_paths_distances

    		# Temporary
    		@nodes = @graph.nodes
    		@edges = @graph.edges

    		# Display all nodes compactly
        @compact_display = true
        place_randomly

      ### TOP 40 ###
      elsif params[:q] == 'last30'

    		# Update graph nodes & edges to include most recent 40 nodes	
    		@graph.get_graph_of_most_recent(limit=30)

    		# Temporary until full conversion
    		@nodes = @graph.nodes
    		@edges = @graph.edges

    		default_layout

      ### TOP RELATIONSHIPS AND THEIR NODES ###
      elsif params[:q] == 'mostcited' 
  	    @graph.get_graph_of_most_cited(limit=30)
  		  # This is a very sparse graph, not recommended for all pairs paths.

      	# Temporary until full conversion
    		@nodes = @graph.nodes
    		@edges = @graph.edges

    		default_layout

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
  	  # Create graph of the first 40 issues, which are fairly interconnected
  	  @graph.get_default_graph

  	  # Temporary
  	  @nodes = @graph.nodes
  	  @edges = @graph.edges
      
      default_layout
    end
  end

  # generates a random graph
  def random_graph(node_count, edge_ratio)
    @nodes = Hash.new()
    @edges = Hash.new()
    @adjacency = Hash.new(0)
    (1..node_count).each {|i| @nodes[i] = Graph::Node.new(i, "Node "+i.to_s, "myurl")} #make random nodes
    for i in (1..node_count)
      for j in (1..node_count) #edges in both directions, chance of 1 each way
        if(i!=j and rand() < edge_ratio) #make random edges
          rel_type = (rand()*10).ceil #get a random set of attributes (rel_type) for that edge
          @edges[j*node_count+i] = Graph::Edge.new(j*node_count+i, @nodes[i], @nodes[j], rel_type)
          @adjacency[[i,j]] += 1 #count the edge
        end
      end
    end
  end

  # returns whether anything in this graph is highlighted or not.
  # version in helper currently being used
  def has_highlighted?(edgeset=@edges)
    edgeset.values.find {|e| e.rel_type & MapvisualizationsHelper::HIGHLIGHTED != 0} != nil
  end

  #places the static nodes at their desired locations
  def set_static_nodes(width=@width, height=@height, nodeset=@nodes)
    nodeset.each_value do |node|
      if node.static == 'center' #using ifthen instead of case so that we can break once we find something
        node.location = Vector[width/2,height/2]
      elsif node.static == 'left'
        node.location = Vector[0,height/2]
      elsif node.static == 'right'
        node.location = Vector[width,height/2]
      elsif node.static == 'top'
        node.location = Vector[width/2,0]
      elsif node.static == 'bottom'
        node.location = Vector[width/2,height]
      elsif node.static == 'top_left'
        node.location = Vector[0,0]
      elsif node.static == 'top_right'
        node.location = Vector[width,0]
      elsif node.static == 'bottom_left'
        node.location = Vector[0,height]
      elsif node.static == 'bottom_right'
        node.location = Vector[width,height]
      elsif node.static == 'stationary' #just leave at location
      end
      #can add other handlers if needed
    end
  end
  
  # a layout for making a graph around a set of target nodes. target_ids is an array of numbers (ids)
  def target_layout(target_ids, nodeset=@nodes, edgeset=@edges)
    groups = {'inc_targ'=>{}, 'dec_targ'=>{}, 'targ_inc'=>{}, 'targ_dec'=>{}, 'sup_targ'=>{}, 'targ_sup'=>{}} #sup_targ = top

    if nodeset.length > 0
      nodeset.each do |id, node| #build our groupings
        if !node.static
          edgeset.values.each do |edge|
            # check if node is related to something in target_ids
            if (node == edge.a and target_ids.include? edge.b.id) # means that node points at target
              g = edge.rel_type & MapvisualizationsHelper::INCREASES != 0 ? 'inc_targ' : (edge.rel_type & 
                  MapvisualizationsHelper::SUPERSET == 0 ? 'dec_targ' : 'sup_targ') #what group we go in
              groups[g][node.id] = node
              break #stop looking for edges for this node
            elsif (node == edge.b and target_ids.include? edge.a.id) #means that target points at node
              g = edge.rel_type & MapvisualizationsHelper::INCREASES != 0 ? 'targ_inc' : (edge.rel_type & 
                  MapvisualizationsHelper::SUPERSET == 0 ? 'targ_dec' : 'targ_sup') #what group we go in
              groups[g][node.id] = node
              break #stop looking for edges for this node
            end
          end
        end
      end 

      set_static_nodes
      static_wheel_nodes

      # put the groups into little circles in their respective corners, so they can come out fighting
      radius = 50
      circle_nodes_at_point(groups['inc_targ'], Vector[0,@height], radius)
      circle_nodes_at_point(groups['dec_targ'], Vector[0,0], radius)
      circle_nodes_at_point(groups['sup_targ'], Vector[@width/2,0], radius)
      circle_nodes_at_point(groups['targ_inc'], Vector[@width,@height], radius)
      circle_nodes_at_point(groups['targ_dec'], Vector[@width,0], radius)
      circle_nodes_at_point(groups['targ_sup'], Vector[@width/2,@height], radius)
            
      #fruchterman_reingold(100) #fast, little bit of layout for now
      kamada_kawai
      normalize_graph
    else
      @nodes = NO_ITEM_ERROR
    end
  end
  

  # the default set of layout commands (hopefully not slow)
  def default_layout(width=@width, height=@height)
    if @nodes.length > 0
      set_static_nodes(width,height)
      static_wheel_nodes(width,height)
      fruchterman_reingold(100,width,height) #fast, little bit of layout for now
      normalize_graph(width,height)
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
      center[0] + (radius * Math.sin(Math::PI/4+2*Math::PI*i/nodeset.length)), 
      center[1] - (radius * Math.cos(Math::PI/4+2*Math::PI*i/nodeset.length))] if !nodeset[key].static}
  end

  # puts the specified nodes in a wheel at the specified point with a specified radius
  # IGNORES STATIC PROPERTY
  def circle_nodes_at_point(nodeset=@nodes, center=Vector[@width/2,@height/2], radius=[@width,@height].min/2, reverse=false, offset=0)
    nodeset.each_with_index{|(key, node), i| nodeset[key].location = Vector[
      center[0] + (radius * Math.sin(offset+2*Math::PI*i/nodeset.length)), 
      center[1] - (radius * Math.cos(offset+2*Math::PI*i/nodeset.length))]}
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
    radius = (static.length<=1 ? 0 : [width,height].min/5)
    static.each_with_index{|(key, node), i| static[key].location = Vector[
      center[0] + (radius * -1*Math.cos(2*Math::PI*i/static.length)), 
      center[1] + (radius * -1*Math.sin(2*Math::PI*i/static.length))]}
  end

  # put the nodes into a grid that will fit in the given canvas
  def grid_nodes(width=@width, height=@height, nodeset=@nodes)
    num_cols = (Math.sqrt(nodeset.length)*(width/height)).ceil
    num_rows = (nodeset.length/num_cols.to_f).ceil
    col_len = width/num_cols
    row_len = height/num_rows
    nodeset.each_with_index{|(key, node), i| nodeset[key].location = 
      Vector[(0.5 + (i%num_cols))*col_len,(0.5 + (i/num_cols))*row_len] if !nodeset[key].static}
  end

  # puts the specified nodes in a grid within the specified box
  # IGNORES STATIC PROPERTY
  def grid_nodes_in_box(nodeset=@nodes, topleft=Vector[0,0], size=Vector[@width,@height], spacing=Vector[0,0])
    num_cols = (Math.sqrt(nodeset.length)*(size[0]/size[1].to_f)).round
    num_rows = (nodeset.length/num_cols.to_f).ceil
    col_len = size[0]/num_cols
    row_len = size[1]/num_rows
    nodeset.each_with_index{|(key, node), i| nodeset[key].location = 
      Vector[topleft[0] + (0.5 + (i%num_cols))*col_len + spacing[0]*i, topleft[1] + (0.5 + (i/num_cols))*row_len + spacing[1]*i]}
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
              #v.d += distlen != 0.0 ? (dist/distlen)*(k2/distlen) : Vector[(-0.5+rand())*0.1,(-0.5+rand())*0.1]
              if distlen != 0.0
                v.d += (dist/distlen)*(k2/distlen)
              else #at the same spot, so just splut them apart a little this run
                v.d += Vector[0.01,0]
                u.d += Vector[-0.01,0]
              end
            end
          end
        end
      end
      for e in edgeset.values do #calc attractive forces
        #only changes 1/conn (assuming 1 edge each direction)
        # if e.a.id < e.b.id or adjacency[[e.a.id,e.b.id]]+adjacency[[e.b.id,e.a.id]] < 2
          dist = e.a.location - e.b.location
          distlen = dist.r.to_f
          fa = distlen**2/k
          delta = (dist/distlen)*fa
          e.a.d -= delta if !e.a.static
          e.b.d += delta if !e.b.static
        # end
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
      #puts "finished iter "+i.to_s+" @ "+Time.now.to_s
    end
    puts "finished fruchterman_reingold @ "+Time.now.to_s
  end

  # adapted from http://code.google.com/p/foograph/source/browse/trunk/lib/vlayouts/kamadakawai.js?r=64
  # this seems to work best for connected graphs; may need to do something to adjust that 
  def kamada_kawai(width=@width, height=@height, nodeset=@nodes, edgeset=@edges, adjacency=@adjacency)
    puts "beginning kamada_kawai @ "+Time.now.to_s

    #calculate shortest path distance (Floyd-Warshall); could be sped up using Johnson's Algorithm (if needed)
    @path_distance = Hash.new(0)
    edgeset.values.each {|e| @path_distance[[e.a.id,e.b.id]] = @path_distance[[e.b.id,e.a.id]] = 1} #fill with L1 dist (non-directional)
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

    ## stuff for maybe doing kamada with the current dist functions
    # distances = @graph.get_all_pairs_paths_distances
    # #puts distances
    # k = 1.0 #spring constant
    # tolerance = 0.001 #epsilon for energy
    # maxlen = 0
    # inf = 1.0/0
    # distances.values.each {|h| h.values.each {|v| maxlen = [maxlen, v].max if v != inf}} #clean this up?
    # l0 = [width,height].min/maxlen #optimal average length
    # ideal_length = Hash.new(0)
    # spring_strength = Hash.new(0)
    # distances.each do |k1,d|
    #   d.each do |k2,val|
    #     if val != inf
    #       ideal_length[[k1,k2]] = l0*val
    #       spring_strength[[k1,k2]] = k/(val*val)
    #     end
    #   end
    # end
    #   
    # puts maxlen
    # #puts ideal_length
    
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
            
      scale = [center[0].to_f/(far_x-center[0]).abs, #currently stretches to fill
               center[1].to_f/(far_y-center[1]).abs]
      scale[0] = 1 if scale[0] == 1.0/0 #if we don't need to stretch, then don't!
      scale[1] = 1 if scale[1] == 1.0/0

      nodeset.each_value {|n| n.location = Vector[scale[0]*(n.location[0]-center[0])+center[0],       
                                                  scale[1]*(n.location[1]-center[1])+center[1]] if !n.static}
    end
  end

end
