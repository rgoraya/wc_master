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
			@cause_id = a
			@issue_id = b
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
			return "#{@cause_id} #{@rel_type} #{@issue_id}"
		end
	end

	# End subclass definitions

	validates_presence_of :nodes, :edges, :source

	# Initialization and Attributes
	attr_accessor :nodes, :edges, :source

	def initialize(issues)
		issues_to_graph = Issue.find(issues)
		update_graph_contents(issues_to_graph)
	end

	def initialize
		# Generates empty graph which can be filled later
		@nodes = Hash.new()
		@edges = Array.new()
		@source = -1
	end

	def update_graph_contents(issues, source = -1)
		# Clear existing nodes and edges, regenerate from input issues
		@nodes = Hash.new()
		@edges = Array.new()
		@source = source

		# Build map of nodes from input issues
		issues.each {|issue| @nodes[issue.id] = (Node.new(issue.id, issue.title, issue.wiki_url))} if !issues.nil?

		# Build list of edges from relationships between existing nodes	
		relationships = Relationship.where("relationships.issue_id IN (?) AND relationships.cause_id IN (?)", @nodes.keys, @nodes.keys)
		relationships.each do |r|
			type = Edge::RELTYPE_TO_BITMASK[r.relationship_type]
			@edges << Edge.new(r.id, r.cause_id, r.issue_id, type)
		end if !relationships.nil?
	end

	def get_nodes()
		return @nodes
	end

	def get_edges()
		return @edges
	end

	# Custom graph generation
	def get_graph_of_path(src, dest, limit)
		# On hold, might move
	end

	def get_graph_of_effects(issue, steps=1)
		# On hold
	end

	def get_graph_where (condition, limit=50)
		# Placeholder - Will spice this up later
	end

	def get_graph_of_most_recent(limit=50)
		# Creates a graph of most recently updated issues (default limit 50)
		issues = Issue.order("updated_at DESC").limit(limit)
		update_graph_contents(issues)
	end

	def get_graph_of_earliest(limit=50)
		# Creates a graph of the earliest created issues (default limit 50)
		issues = Issue.order("created_at ASC").limit(limit)
		update_graph_contents(issues)
	end
	
	def get_graph_of_most_connected (limit=50)	
		# Placeholder - functionality available in an unmerged branch...
	end

	def get_graph_of_all
		# Creates a graph of all of the issues
		issues = Issue.find :all
		update_graph_contents(issues)
	end
end
