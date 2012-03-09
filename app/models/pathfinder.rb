class Pathfinder
	include ActiveModel::Validations

	attr_accessor :source, :destination

	def initialize(source=0, destination=0)
		@source = source
		@destination = destination
	end

	# Different types of generations (src/dest, all-pairs, etc)
	def path_from_src_to_dest(graph, src=0, dest=0)
		# Update source and destination
		@source, @destination = src, dest

		# Check if source and destination are 0
		# if so return empty path
		if @source == 0 and @destination == 0
			return []
		end

		# Generate a connections hash based on graph edges
		outgoing = Hash.new()
		graph.edges.each do |edge|
			# Probably a more graceful way to do this
			if not outgoing.has_key?(edge.a)
				outgoing[edge.a] = {}
			end

			# Is it possible for any two issues to have multiple links
			# between them?
			outgoing[edge.a][edge.b] = edge
		end

		# If an edge already exists in the graph from source to destination
		if outgoing[src].has_key?(dest)
			return Array[ outgoing[src][dest].id ]
		end
				
		return []
	end
end
