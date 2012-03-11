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
			
		# Compute all paths from source
		paths_tracer, relationships_on_paths = compute_paths_from_source(outgoing, nodes)
		
		# Find the shortest path through the graph between source and destination
		if destination != 0
			return trace_path_from_source(outgoing, paths_tracer)
		end

		return relationships_on_paths
	end

	def compute_paths_from_source(e, v)
		# Computes shortest path given specific src/dest
		return []
	end

	def trace_path_from_source(edges, tracer)
		# Computes all paths given a source node
		return []
	end

	def compute_all_pairs_paths(e, v)
	end
end
