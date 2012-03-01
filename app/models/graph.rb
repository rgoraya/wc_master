require 'matrix'

class Graph
	include ActiveModel::Validations

	# Begin subclass definitions
	class Node
		include	ActionView::Helpers::JavaScriptHelper #for javascript escaping

	    attr_accessor :id, :name, :url, :location, :static, :highlighted, :d, :a

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
		end

		def to_s
			@id.to_s + ": "+@location.to_s+" ("+@name.to_s + ")"
	    end
	end	

	class Edge
		include	ActionView::Helpers::JavaScriptHelper #for javascript escaping
		
		attr_accessor :id, :a, :b, :rel_type

		# A placeholder converter for building the edges
		RELTYPE_TO_BITMASK = {nil=>MapvisualizationsHelper::INCREASES, 'I'=>MapvisualizationsHelper::DECREASES, 'H'=>MapvisualizationsHelper::SUPERSET}

		def initialize(id, a, b, rel_type)
			@id = id
			@a = a
			@b = b
			@rel_type = rel_type
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

	validates_presence_of :nodes, :edges, :sources

	# Initialization and Attributes
	attr_accessor :nodes, :edges, :sources

	def initialize(issues)
		issues_to_graph = Issue.find(issues)
		update_graph_contents(issues_to_graph)
	end

	def initialize
		# Generates empty graph which can be filled later
		@nodes = Hash.new()
		@edges = Array.new()
		@sources = Array.new()
	end

	def update_graph_contents(issues, relationships=nil, source_set=[])
		# Clear existing nodes and edges, regenerate from input issues
		@nodes = Hash.new()
		@edges = Array.new()
		@sources = source_set

		# Build map of nodes from input issues
		issues.each {|issue| @nodes[issue.id] = (Node.new(issue.id, issue.title, issue.wiki_url))} if !issues.nil?

		# Build list of edges from relationships between existing nodes, if no relationships set is predefined	
		if relationships.nil?
			relationships = Relationship.where("relationships.issue_id IN (?) AND relationships.cause_id IN (?)", @nodes.keys, @nodes.keys)
		end
		
		# Build graph edges from relationships
		relationships.each do |r|
			type = Edge::RELTYPE_TO_BITMASK[r.relationship_type]
			@edges.push(Edge.new(r.id, @nodes[r.cause_id], @nodes[r.issue_id], type))
		end
		
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
		# TO DO: Currently neighbors are just the first 40 or so retrieved...need to determine best algorithm for this.		
		issues = Issue.where("id" => core_issues)
			
		neighbors = Issue.where("issues.id NOT IN (?)", core_issues)
			.joins(:relationships).where("relationships.issue_id IN (:get_issues) OR relationships.cause_id IN (:get_issues)", 
			{:get_issues => core_issues}).limit(limit)
		
		# This is taking a random sample of n neighbors, along with the static/core issues...
		update_graph_contents(issues + neighbors)
	end

	def get_graph_of_most_cited(limit=40)
		# Generates graph of most cited / highly rated / recent relationships and their endpoints
		relationships = Relationship.order("references_count DESC, updated_at DESC").limit(limit)
			
		endpoints = relationships.flat_map {|r| [r.cause_id, r.issue_id]}

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
		core_relationships = Relationship.where("id" => relationships_ids)

		# Retrieve relationship endpoint issues
		endpoints = core_relationships.flat_map {|r| [r.cause_id, r.issue_id]}.uniq
		issues = Issue.where("id" => endpoints)

		# Retrieve neighbors to endpoints
		neighbors = Issue.where("issues.id NOT IN (?)", endpoints)
			.joins(:relationships).where("relationships.issue_id IN (:connected) OR relationships.cause_id IN (:connected)", 
			{:connected => endpoints}).limit(limit)
		extended_endpoints = endpoints + neighbors.flat_map {|n| [n.id, n.id]}.uniq
		
		# Extend relationships with those connected to endpoints and core issues
		relationships = Relationship.where("cause_id IN (?) AND issue_id IN (?)", extended_endpoints, extended_endpoints)
	
		update_graph_contents(issues + neighbors, relationships, endpoints)
	end

	### Future Implementation ###
	# get_graph_of_path(src, dest, limit)
	# get_graph_where (condition, limit=40)
	# get_graph_of_most_connected (limit=40)	
end
