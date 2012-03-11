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
		nodes = graph.nodes.keys
		result = Array.new()

		graph.nodes.keys.each {|key| outgoing[key] = Hash.new() }
		graph.edges.each do |edge|
			# Is it possible for any two issues to have multiple links
			# between them?
			outgoing[edge.a.id][edge.b.id] = edge		
		end

		# If an edge already exists in the graph from source to destination
		if outgoing[@source].has_key?(@destination)
			result.push(outgoing[@source][@destination].id)
			return result
		end
				
		# Find the shortest path through the graph between source and destination
		if destination == 0
			# If no destination specified find all pairs from source
			return compute_paths_from_src(outgoing, nodes)

		else
			# If destination specified find that path
			return compute_path_src_dest(outgoing, nodes)

		end

	end

	def compute_path_src_dest(e, v)
		# Computes shortest path given specific src/dest
		return []
	end

	def compute_paths_from_src(e, v)
		# Computes all paths given a source node
		return []
	end

	def compute_all_pairs_paths(e, v)
	end
end
