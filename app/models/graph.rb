require 'matrix'

class Graph
	include ActiveModel::Validations

	# Begin subclass definitions
	class Node
	  attr_accessor :id, :name, :url, :location, :static, :highlighted, :d, :a, :on_path

		def initialize(id, name, url)
			# Basic node members
			@id = id
			@name = name
			@url = url

			# Visualization members
			@location = Vector[0.0,0.0]
			@static = false #should the node move or not
			@highlighted = false
			@d = Vector[0.0,0.0] #delta variable
			@a = Vector[0.0,0.0] #acceleration variable

			# Path-Tracking members	
			@on_path = 0
		end

		def to_s
			@id.to_s + ": "+@location.to_s+" ("+@name.to_s + ")"
	    end

		def node_id
			return @id
		end
	end	

	class Edge

		attr_accessor :id, :a, :b, :rel_type, :edge_on_path, :expandable

		# A placeholder converter for building the edges
		RELTYPE_TO_BITMASK = {nil=>MapvisualizationsHelper::INCREASES, 'I'=>MapvisualizationsHelper::DECREASES, 'H'=>MapvisualizationsHelper::SUPERSET}

		def initialize(id, a, b, rel_type)
			@id = id
			@a = a
			@b = b
			@rel_type = rel_type
			@edge_on_path = false
			@expandable = false
		end

		def to_s
			"Edge "+@id.to_s+": "+name
		end

		def name
			conn = @rel_type & MapvisualizationsHelper::INCREASES != 0 ? 'increases' : (@rel_type & MapvisualizationsHelper::SUPERSET == 0 ? 'decreases' : 'includes')
			@a.name+" "+conn+" "+@b.name
		end

		# Placeholder for debugging
		def edge_to_s
			return "#{@a.name} #{@rel_type} #{@b.name}"
		end
	end

	# End subclass definitions

	validates_presence_of :nodes, :edges

	# Initialization and Attributes
	attr_accessor :nodes, :edges, :sources, :pathfinder, :layout_distances

	def initialize(issues)
		issues_to_graph = Issue.find(issues)
		update_graph_contents(issues_to_graph)
		@pathfinder = Pathfinder.new()
		@layout_distances = Hash.new()
	end

	def initialize
		# Generates empty graph which can be filled later
		@nodes = Hash.new()
		@edges = Array.new()
		@sources = Array.new()

		# Pathfinder tool and shortest distance placeholder
		@pathfinder = Pathfinder.new()
		@layout_distances = Hash.new()
	end

	def update_graph_contents(issues, relationships=nil, source_set=[])
		# Clear existing nodes and edges, regenerate from input issues
		@nodes = Hash.new()
		@edges = Array.new()
		@layout_distances = Hash.new()
		@sources = source_set

		# Build map of nodes from input issues
		issues.each {|issue| @nodes[issue.id] = (Node.new(issue.id, issue.title, issue.wiki_url))} if !issues.nil?

		# Build list of edges from relationships between existing nodes, if no relationships set is predefined	
		if relationships.nil?
			relationships = Relationship.where("issue_id IN (?) AND cause_id IN (?)", @nodes.keys, @nodes.keys)
		end
		
		# Build graph edges from relationships
		relationships.each do |r|
			type = Edge::RELTYPE_TO_BITMASK[r.relationship_type]
			@edges.push(Edge.new(r.id, @nodes[r.cause_id], @nodes[r.issue_id], type))
		end
		
	end

	def update_graph_contents_with_select_relationship(issues, relationships, source_set=[])
		# Relationship-focused graph generation
		@nodes = Hash.new()
		@edges = Array.new()
		@layout_distances = Hash.new()
		@sources = source_set

		# Build map of nodes from input issues
		issues.each {|issue| @nodes[issue.id] = (Node.new(issue.id, issue.title, issue.wiki_url))} if !issues.nil?
		connections = Relationship.where("issue_id IN (?) AND cause_id IN (?)", @nodes.keys, @nodes.keys)

		connections.each do |r|
			if relationships.include?(r.id)
				type = Edge::RELTYPE_TO_BITMASK[r.relationship_type]
				@edges.push(Edge.new(r.id, @nodes[r.cause_id], @nodes[r.issue_id], type))
			end
		end
	end

	### Query-Based Path Generation ###
	def check_path_src_dest(src, dest)
		# Check source validity
		src_check = Issue.find_by_id(src)
		if src_check.nil?
			return -1
		end

		# Check destination validity
		dest_check = Issue.find_by_id(dest)
		if dest_check.nil?
			return 0
		end

		# Source and Destination are valid
		return 1

	end

	def get_graph_of_path(src, dest)
		# Retrieve all issues and update graph contents
		issues = Issue.find :all
		update_graph_contents(issues)
		
		# Creates a graph of a shortest path between two nodes based on query input
		relations = @pathfinder.path_from_src_to_dest(self, src, dest)
		
		if relations.keys.length > 0
			# Retrieve issue endpoints
			endpoints = Relationship.where("id" => relations.keys).flat_map {|r| [r.issue_id, r.cause_id]}
			issues = Issue.where("id" => endpoints)
			update_graph_contents_with_select_relationship(issues, relations.keys)

			# Add nodes and edges to path
			@edges.each {|edge| edge.edge_on_path = 1 }
			@nodes.values.each {|node| node.on_path = 1 }

			# Return success
			return 1
		else
			targets = [src, dest]
			edges = Relationship.where("issue_id IN (?) OR cause_id IN (?)", targets, targets).flat_map {|r| [r.issue_id, r.cause_id]}
			neighbors = edges.uniq.select {|c| !targets.include? c }

			issues = Issue.where("id IN (?) OR id IN (?)", targets, neighbors).order("created_at ASC").limit(20)
     		issues += Issue.where("id in (?)",targets) ## THIS COULD PROBABLY BE CLEANER
      
			update_graph_contents(issues)
		end

		# Default to no path found
		# In the future, might want to add another case for "best effort"
		return 0 # if disconnected
	end

	def highlight_path_in_graph(src, dest)
		# Highlights a path, if it exists, in current graph structure.
		# Updates "on-path" member of a Node 
		
	end

	def get_all_pairs_paths_distances
		# Runs all pairs shortest path on current graph in system
		
		# Check if this graph has nodes
		if (@nodes.length == 0 or @edges.length == 0)
			return {}
		end

		# Generate connections and vertices
		connections = Hash.new()
		vertices = @nodes.keys

		vertices.each { |key| connections[key] = Hash.new() }
		@edges.each do |edge| 
			connections[edge.a.id][edge.b.id] = edge
			connections[edge.b.id][edge.a.id] = Edge.new(-1*edge.id, @nodes[edge.b.id], @nodes[edge.a.id], edge.rel_type)
		end

		@layout_distances = @pathfinder.compute_all_pairs_undirected_paths(connections, vertices)

		@layout_distances.each do |src, dests|
			dests.each do |k, v|
			### DEBUG
        # puts "DISTANCE #{src} to #{k}: #{v}"
			end 
		end

		return @layout_distances
	end

	### Custom query based graph generation ###

	def get_graph_of_most_recent(limit=40)
		# Creates a graph of most recently updated issues (default limit 40)
		issues = Issue.order("updated_at DESC").limit(limit)
		
		update_graph_contents(issues)
	end

	def get_graph_of_issue_neighbors(core_issues, limit=40, steps=1)
		# Retrieves any nodes connected to node(s) in issues array
		# currently only set up for one step, but optional to add more in the future

		# Initial core, neighbors, and seeded generation queue
		core = Array.new(core_issues)
		max_issues = limit + core_issues.size
		
		# Update core in successive steps outward from target issues
		while core.size < max_issues

			# Retrieve next step connections based on relationships connected to core
			neighbors = Relationship.where("issue_id IN (?) OR cause_id IN (?)", core, core).flat_map {|r| [r.issue_id, r.cause_id]}.uniq.select {|c| !core.include? c }
      
      break if neighbors.length == 0 #break out if we have no more neighbors.
      
			# Add neighbors if space remains below limit
			space_remaining = [neighbors.size, max_issues - core.size].min
			neighbors.take(space_remaining).each{ |c| core << c }
		end	

		# Generate graph base from latest core issues and neighbors
		issues = Issue.where("id" => core)

		update_graph_contents(issues)
	end

	def get_graph_of_most_cited(limit=40)
		# Generates graph of most cited / highly rated / recent relationships and their endpoints
		relationships = Relationship.order("references_count DESC, updated_at DESC").limit(limit)
			
		endpoints = relationships.flat_map {|r| [r.cause_id, r.issue_id]}.uniq

		issues = Issue.where("id" => endpoints)

		update_graph_contents(issues, relationships)
	end

	def get_graph_of_earliest(limit=40)
		# Creates a graph of the earliest created issues (default limit 40)
		issues = Issue.order("created_at ASC").limit(limit)
		update_graph_contents(issues)
	end

	def get_default_graph
		# Bridge for default case in MapVisualization Model
		get_graph_of_earliest
	end

	def get_graph_of_all
		# Creates a graph of all of the issues
		issues = Issue.find :all
		update_graph_contents(issues)
	end

	def get_graph_of_relationship_endpoints(relationships_ids, limit=40)
		# Retrieves issues connected to relationship endpoints
		# then retrieves random (for now) subset of neighbors of those issues
		# TO DO: Currently neighbors are just the first 40 or so retrieved...need to determine best algorithm for this.

		# Find source relationship endpoints		
		endpoints = Relationship.where("id" => relationships_ids).flat_map {|r| [r.cause_id, r.issue_id]}.uniq
		issues = Issue.where("id" => endpoints)

		# Retrieve neighbors to endpoints
		step_endpoints = Relationship.where("issue_id IN (?) OR cause_id in (?)", endpoints, endpoints).flat_map {|r| [r.cause_id, r.issue_id]}.uniq.select {|e| !endpoints.include? e }
		neighbors = Issue.where("id" => step_endpoints).limit(limit)
		
		# Extend relationships with those connected to endpoints
		extended_endpoints = endpoints + step_endpoints
	
		update_graph_contents(issues + neighbors, nil, endpoints)
	end
end
