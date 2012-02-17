class Graph
	include ActiveModel::Validations

	validates_presence_of :nodes, :edges

	# Initialization and Attributes
	attr_accessor :nodes, :edges
	def initialize(issues)
		# Generates nodes from list of issues
		@nodes = [] # To do: initialize with Node class

		# Retrieve relationships between issues
		@edges = [] # To do
	end

	def initialize
		# Basic empty graph
		@nodes = [] # Initialize as empty list of node objects?
		@edges = [] # Initialize as empty list of edges?
	end

	# Custom graph generation
	def get_graph_of_path(src, dest, limit)
	end

	def get_graph_of_effects(issue, steps, limit)
	end

	def get_graph_where (condition, limit)
	end

	def get_graph_of_most_recent (limit)
	end
	
	def get_graph_of_most_connected (limit)
    end

	def get_graph_of_all
	end

	def get_graph_of_nas
	end

	# PathFinding
end


