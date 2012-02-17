require 'active_model'

class Graph
	include ActiveModel::Validations

	validates_presence_of :nodes, :edges

	attr_accessor :nodes, :edges
	def initialize(issues)
		# Generates nodes from list of issues
		@nodes = issues # To do: initialize with Node class

		# Retrieve relationships between issues
		@edges = {}
	end

	def initialize
		# Basic empty graph
		@nodes = []
		@edges = []
	end

	

end


