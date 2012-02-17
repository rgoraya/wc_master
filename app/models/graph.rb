class Graph
	include ActiveModel::Validations

	validates_presence_of :nodes, :edges

	# Initialization and Attributes
	attr_accessor :nodes, :edges
	def initialize(issues)
		# Generates nodes from list of issues
		@nodes = [] # To do: initialize with Mapviz::Node class

		# Retrieve relationships between issues
		@edges = [] # To do: Initialize with Mapviz::Edge

		# Placeholder for history
	end

	def initialize
		# Generates empty graph which can be filled later
		@nodes = []
		@edges = []

		# Placeholder for history
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

	# Path finding
end


