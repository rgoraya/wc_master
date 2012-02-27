class Graph
	include ActiveModel::Validations

	# Begin subclass definitions
	class Node
		def initialize(id, name, url)
			@id = id
			@name = name
			@url = url
		end

		def get_name
			return @name		
		end
	end	

	class Edge
		def initialize(a, b, rel_type)
			@cause_id = a
			@issue_id = b
			@rel_type = rel_type
		end

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
		@nodes = []
		@edges = []
		@source = -1
	end

	def update_graph_contents(issues, source = -1)
		# Clear existing nodes and edges, regenerate from input issues
		@nodes = []
		@edges = []
		@source = source

		# Build issues and retrieve their relationships
		issues.each do |issue|
			relationships = Relationship.where("cause_id == ?", issue.id)

			@nodes << Node.new(issue.id, issue.title, issue.wiki_url)
			relationships.each do |r|			
				@edges << Edge.new(r.cause_id, r.issue_id, r.relationship_type)
			end
		end
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
