require 'matrix'

class Game < Mapvisualization #subclass Mapvis, so we can use it for layout and stuff

  START = 19

  def initialize(args)
    puts "===game initialize args===" #debugging
    puts args

    @width, @height = args[:width], args[:height]

	  # Build a Graph of Nodes
  	@graph = Graph.new
  	@nodes = @graph.nodes
  	@edges = @graph.edges
    @adjacency = Hash.new(nil)

    if args[:blank]
      make_blank_graph

    elsif args[:edges]
      make_user_graph(args[:edges])
    
    elsif args[:expert]
      show_expert_graph(args[:expert])    
    end
  end

  # make the nodes and edges for our expert graph
  def make_blank_graph
    ISSUE_NAMES.each_with_index {|name, i| @nodes[i] = Graph::Node.new(i, name, "") unless name.blank? }

    #testing
    #@edges.push(Graph::Edge.new(1, @nodes[0], @nodes[3], MapvisualizationsHelper::INCREASES))

    @nodes[START].location = Vector[(@width-200)/2, @height/2] #pull out Menhaden Population and center
    grid_nodes_in_box(@nodes.reject{|k,v| k==START},Vector[@width-200+50, 130],Vector[200, @height-130+50]) #hard-coded starting box
  end

  def show_expert_graph(num)
    ISSUE_NAMES.each_with_index {|name, i| @nodes[i] = Graph::Node.new(i, name, "") unless name.blank? }
    
    EXPERT_GRAPHS[num].each_with_index {|(key, value), i| @edges.push(Graph::Edge.new(i, @nodes[key[0]-1], @nodes[key[1]-1], (value > 0 ? MapvisualizationsHelper::INCREASES : MapvisualizationsHelper::DECREASES))) }
    
    default_layout
  end

  def make_user_graph(edges)
    puts "MAKING USER GRAPH FROM",edges.to_s

    @nodes[START] = Graph::Node.new(START,ISSUE_NAMES[START],"") #have at least the one node (Mehanad Population) to start with...

    #construct the nodes
    edges.each do |key, edge|
      if key != 'keys'
        a = edge[:a] #simple access
        b = edge[:b]
        a[:id] = a[:id].to_i #for speed
        b[:id] = b[:id].to_i
        @nodes[a[:id]] = Graph::Node.new(a[:id], a[:name], a[:url]) #will overwrite previous declarations if any
          @nodes[a[:id]].location = Vector[a[:x].to_i, a[:y].to_i]
        @nodes[b[:id]] = Graph::Node.new(b[:id], b[:name], b[:url])
          @nodes[b[:id]].location = Vector[b[:x].to_i, b[:y].to_i]
      end
    end
    # puts @nodes

    # construct the edges; do it after nodes exist so we can use references
    # adjacency for quick access of which edges exist, and what their values are (fwiw)
    edges.each do |key, edge|
      if key != 'keys'
        new_edge = Graph::Edge.new(edge[:id].to_i, @nodes[edge[:a][:id]], @nodes[edge[:b][:id]], edge[:reltype].to_i)
        @edges.push(new_edge)
        @adjacency[ [edge[:a][:id]+1, edge[:b][:id]+1, (edge[:reltype].to_i == 1 ? 1 : -1)] ] = new_edge
      end
    end
    # puts @edges
    # puts @adjacency

  end

##############################
### RUNNING THE SIMULATION ###
##############################

  def compare_to_expert
    puts "compare_to_expert"
    
    correct = make_accuracy_matrix #first-order matrix, should figure out how to get higher order ones (from path stuff?)
    
    score = 0 #total accuracy score
    @adjacency.each do |key, value|
      score += correct[key]
    end
    
    ## HOW DOES THIS GET CONVERTED INTO A 'PERCENTAGE' OF ANTS?
      ## assign an 'accuracy' to each edge (a percentage based on the score of that edge)
        ## just scale from -8 to 8 ??
      ## that's the number of ants that make it across the edge?
        ## are we looking for a path, or trying to 'populate/colonize' the islands? Then we just have a single starting node
        ## might work as a demo. Then we can branch out.


    return score
  end

  class Ant
	  attr_accessor :id, :island, :plan
		def initialize(n)
		  @id = n
		  @island = START
		  @plan = [1,2]
	  end
	  def to_s
      "Ant("+@id.to_s+", "+@plan.to_s+")"
    end
  end
	
  # class Island
  #   attr_accessor :id, :ants, :entries
  #   def initialize(id)
  #     @id = id
  #     @ants = []
  #     @entries = []
  #     end
  #   end 
  
  # define all the ants that represent this game simulation!
  def get_ants
    puts "ANT FARM!"
    ants = Array.new
    # islands = Hash.new([]) #islands are just a hash for now, key to node_id, value is array of ants
    # roads = Hash.new(0) #the count of how much traffic each road (edge.id) has seen
    
    #make 100 ants
    num_ants = 20
    (0...num_ants).each do |i|
      ant = Ant.new(i)
      ants.push(ant)
      # islands[ant.island].push(ant)
    end
    
    journeys = [[]]

    #calculate the journeys to take!
    @edges.each do |e| #get the edges that are connected to START, for testing/debugging
      if e.a.id == START or e.b.id == START
        journeys.unshift([e.id]) #add the 1-step journey to the list of paths (pushing on front of stack)
      end
    end

    #divide the journeys among the ants
    ants.each_with_index {|ant,i| ant.plan = journeys[i%journeys.length]}
    

    ### give them a plan!!
    
    ##go through each "island" (which has a subset of the ants)
      ## divide the ants in that island into groups based on the number of out-going edges (ignoring edges that ants have used to get here already?)
      ## max 3 ants decide to "settle", unless there are no more paths to follow?
      
    
    ## THIS IS THE CORRECT ANSWER
    ## calculate all possible paths start from HOME with increasing distance, until our set of paths includes all the edges in the graph.
      ## greedy so that we only get new paths that include new edges
    ## divide up the ants by those paths (less the few that are going to take the '0' path)
    ## that is the plan for each ant!
    
    

    ## once each ant has a plan, check the validity of each edge to see if the ant dies or not, and then mark that edge as such (removing the following bits from the plan)
    
    


    #puts "ants we made", ants
    return ants
  end





################################
### CONSTANTS FOR THE GRAPHS ###
################################

  #we could also hard-code this for speed...
  def make_accuracy_matrix
    matrix = Hash.new

    (1..ISSUE_NAMES.length).each do |i| #for every pair
      (1..ISSUE_NAMES.length).each do |j|
      
        num_incr = 0
        num_decr = 0
        EXPERT_GRAPHS.each_value do |expert| #count how many experts had an edge in each direction
          num_incr += 1 if expert[[i,j]] == 1
          num_decr += 1 if expert[[i,j]] == -1
        end
        
        matrix[[i,j,1]] = RUBRIC[num_incr] #have increase and decrease, so technically 3d matrix
        matrix[[i,j,-1]] = RUBRIC[num_decr]
      end
    end
  
    #matrix.each {|key,value| puts key.to_s+":"+value.to_s if value > 0}
    ### should probably just hard-code this once it's done...
    return matrix
  end

  RUBRIC = {4=>8, 3=>6, 2=>4, 1=>1, 0=>-0.5, -2=>-2, -3=>-4, -4=>-6, -5=>-8} #scores for number of experts in agreement
  
  ISSUE_NAMES = [
    'Algae Blooms/Dead Zones',
    ' ',
    ' ',
    'Bad weather',
    'Amount of samaki caught',
    'Coastal water quality',
    'Cost per unit catch',
    'Society Affluence',
    'Demand for farm-raised fish feed (aquaculture)',
    ' ',
    'Demand for Livestock feed',
    'Demand for Omega-3 as a food supplement',
    'Effort put into catching menhaden',
    'El Nino',
    ' ',
    'Lifespan of menhaden',
    'Management at the ecosystem level',
    'Management of menhaden catch',
    'Marine mammals',
    'Menhaden population',
    'Dissolved oxygen levels',
    'Nutrients in the water',
    'Omega Corporation profits',
    'Predatory bird populations',
    'Public information to increase fish oil intake',
    'Public worry about decrease of menhaden',
    'Reproduction rate of menhaden',
    'Sales price per unit catch',
    'Soybeans sales',
    'Sport fish health',
    'Sport fish populations',
    'Scientific speculation of overfishing',
    'Menhaden industry leaders\' claim of healthy fishery',
    'Disagreement over menhaden poplation health',
    'Price of competing products (soybeans and vegetable oils)',
    'Reproduction rate per unit fish',
    'Production from international fish oil competitors',
    'Amount of sport fish caught',
    'Human population',
    'Food eaten per fish (menhaden)',
  ]

  EXPERT_GRAPH_1 = { #group 1
    [1,6]=>-1,											
    [1,21]=>-1,																			
    [4,7]=>1,																																
    [5,16]=>-1,				
    [5,20]=>-1,			
    [5,23]=>1,				
    [5,28]=>-1,												
    [7,13]=>-1,										
    [7,23]=>-1,																	
    [8,12]=>1,																									
    [8,38]=>1,	
    [9,28]=>1,											
    [11,28]=>1,												
    [12,28]=>1,												
    [13,5]=>1,																																		
    [14,37]=>-1,			
    [16,27]=>1,												
    [17,18]=>1,
    [17,19]=>1,	
    [17,20]=>1,				
    [17,24]=>1,							
    [17,31]=>1,									
    [18,5]=>-1,																																			
    [19,20]=>-1,																				
    [20,1]=>-1,			
    [20,5]=>1,	
    [20,7]=>-1,												
    [20,19]=>1,					
    [20,24]=>1,		
    [20,26]=>-1,					
    [20,31]=>1,
    [20,32]=>-1,								
    [20,40]=>-1,
    [21,6]=>1,												
    [21,20]=>1,																				
    [22,1]=>1,				
    [22,6]=>-1,																																		
    [22,40]=>1,
    [23,13]=>1,																				
    [23,33]=>1,							
    [24,20]=>-1,																				
    [25,12]=>1,																											
    [26,17]=>1,	
    [26,18]=>1,																						
    [27,20]=>1,																				
    [28,13]=>1,										
    [28,23]=>1,														
    [28,37]=>1,			
    [29,35]=>-1,					
    [30,38]=>1,	
    [31,20]=>-1,						
    [31,26]=>-1,											
    [31,38]=>1,	
    [32,17]=>1,	
    [32,18]=>1,								
    [32,26]=>1,														
    [33,18]=>-1,																						
    [35,28]=>1,											
    [37,28]=>-1,												
    [38,30]=>-1,
    [38,31]=>-1,								
    [39,9]=>1,
    [39,11]=>1,	
    [39,12]=>1,										
    [39,22]=>1,													
    [39,35]=>1,					
    [40,20]=>1,   
  }

  EXPERT_GRAPH_2 = { #group 2
    [1,40]=>1,
    [4,5]=>-1,																																			
    [5,20]=>-1,			
    [5,23]=>1,																	
    [6,17]=>1,				
    [6,21]=>-1,																			
    [7,23]=>1,					
    [7,28]=>1,												
    [8,7]=>1,		
    [8,9]=>1,		
    [8,11]=>1,																	
    [8,28]=>1,	
    [8,29]=>1,											
    [9,7]=>1,																					
    [9,28]=>1,												
    [11,7]=>1,																					
    [11,28]=>1,
    [11,29]=>1,											
    [12,7]=>1,																				
    [12,28]=>1,												
    [13,5]=>1,																																			
    [14,5]=>-1,																																			
    [17,6]=>1,												
    [17,19]=>1,
    [17,20]=>1,
    [17,21]=>1,
    [17,22]=>1,	
    [17,24]=>1,		
    [17,27]=>1,		
    [17,30]=>1,
    [17,31]=>1,									
    [18,20]=>1,																				
    [19,17]=>-1,							
    [19,26]=>-1,				
    [19,32]=>-1,	
    [19,34]=>-1,						
    [20,1]=>-1,			
    [20,5]=>1,							
    [20,13]=>-1,				
    [20,18]=>-1,
    [20,19]=>1,		
    [20,24]=>1,				
    [20,30]=>1,
    [20,31]=>1,									
    [21,6]=>1,						
    [21,17]=>1,																							
    [22,1]=>1,							
    [22,17]=>1,																							
    [23,13]=>1,																											
    [24,17]=>-1,					
    [24,26]=>-1,			
    [24,32]=>-1,	
    [24,34]=>-1,						
    [25,7]=>1,		
    [25,12]=>1,						
    [25,28]=>1,												
    [26,17]=>1,
    [26,18]=>1,				
    [26,34]=>1,						
    [27,21]=>1,																			
    [28,13]=>1,								
    [28,23]=>1,																	
    [29,23]=>-1,																	
    [30,17]=>-1,						
    [30,26]=>-1,				
    [30,32]=>-1,	
    [30,34]=>-1,		
    [30,38]=>1,		
    [31,17]=>-1,			
    [31,24]=>1,	
    [31,26]=>-1,			
    [31,32]=>-1,	
    [31,34]=>-1,		
    [31,38]=>1,		
    [32,17]=>1,
    [32,18]=>1,			
    [32,26]=>1,				
    [32,34]=>1,						
    [33,26]=>-1,			
    [33,34]=>1,						
    [34,17]=>1,
    [34,18]=>1,																						
    [35,23]=>1,																	
    [37,23]=>-1,																	
    [38,31]=>-1,	
    [38,33]=>1,							
    [39,6]=>-1,	
    [39,8]=>1,	
    [39,9]=>1,		
    [39,11]=>1,
    [39,12]=>1,				
    [39,21]=>-1,	
    [39,22]=>-1,		
    [39,25]=>1,
    [39,26]=>1,				
    [39,32]=>1,	
    [39,34]=>1,						
    [40,20]=>1,						
    [40,27]=>1,    
  }

  EXPERT_GRAPH_3 = { #individual 1
    [4,20]=>-1,						
    [4,27]=>-1,													
    [6,20]=>-1,						
    [6,27]=>-1,													
    [7,13]=>-1,																											
    [12,28]=>1,												
    [13,5]=>-1,													
    [13,20]=>-1,																				
    [17,13]=>-1,																											
    [18,13]=>-1,																											
    [19,17]=>1,		
    [19,20]=>-1,																				
    [20,5]=>-1,																									
    [20,32]=>1,
    [20,33]=>1,
    [20,34]=>1,						
    [24,17]=>1,		
    [24,20]=>-1,																				
    [25,28]=>1,												
    [27,20]=>1,																				
    [28,13]=>1,																											
    [30,31]=>1,									
    [31,17]=>1,		
    [31,20]=>-1,																				
    [32,17]=>1,
    [32,18]=>1,																						
    [33,18]=>-1,																						
    [39,6]=>-1,						
    [39,22]=>1,		
    [39,28]=>1,												
  }

  EXPERT_GRAPH_4 = { #individual 2
    [1,17]=>1,		
    [1,21]=>-1,			
    [1,31]=>-1,									
    [4,6]=>1,
    [4,7]=>1,																																	
    [5,16]=>-1,		
    [5,19]=>-1,
    [5,20]=>-1,			
    [5,24]=>-1,				
    [5,31]=>-1,
    [5,32]=>1,								
    [6,17]=>-1,	
    [6,19]=>1,
    [6,20]=>1,			
    [6,24]=>1,	
    [6,26]=>-1,		
    [6,30]=>1,	
    [6,31]=>1,			
    [6,38]=>1,		
    [8,9]=>1,																															
    [9,28]=>1,												
    [11,28]=>1,
    [11,29]=>1,			
    [11,35]=>1,					
    [12,28]=>1,												
    [13,5]=>1,											
    [13,20]=>-1,								
    [13,31]=>-1,									
    [14,4]=>1,	
    [14,6]=>1,																																		
    [16,18]=>-1,																						
    [17,6]=>1,								
    [17,19]=>1,			
    [17,23]=>-1,	
    [17,24]=>1,																
    [18,19]=>1,
    [18,20]=>1,		
    [18,23]=>-1,	
    [18,24]=>1,		
    [18,27]=>1,			
    [18,31]=>1,									
    [19,17]=>-1,							
    [19,26]=>-1,														
    [20,6]=>1,
    [20,7]=>-1,			
    [20,18]=>-1,
    [20,19]=>1,	
    [20,24]=>1,		
    [20,31]=>1,
    [20,32]=>-1,	
    [20,33]=>1,							
    [21,17]=>-1,										
    [21,31]=>1,									
    [22,1]=>1,			
    [22,6]=>-1,								
    [22,17]=>1,																							
    [23,7]=>-1,																																	
    [24,17]=>-1,					
    [24,26]=>-1,														
    [25,12]=>1,																												
    [27,18]=>-1,	
    [27,20]=>1,																				
    [28,23]=>1,																	
    [29,35]=>-1,					
    [30,38]=>-1,		
    [31,17]=>-1,					
    [31,26]=>-1,			
    [31,30]=>-1,			
    [31,38]=>1,		
    [32,6]=>1,								
    [32,18]=>1,																						
    [33,23]=>1,																	
    [34,33]=>1,							
    [36,6]=>1,							
    [36,18]=>-1,		
    [36,20]=>1,																				
    [37,12]=>-1,																												
    [38,31]=>-1,									
    [39,1]=>1,			
    [39,6]=>-1,		
    [39,9]=>1,						
    [39,22]=>1,		
    [39,31]=>-1,									
    [40,16]=>1,									
    [40,27]=>1,							
    [40,36]=>1,
  }

  EXPERT_GRAPHS = {'1' => EXPERT_GRAPH_1, '2' => EXPERT_GRAPH_2, '3' => EXPERT_GRAPH_3, '4' => EXPERT_GRAPH_4}
  
end
