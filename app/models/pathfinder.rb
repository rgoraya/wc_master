class Pathfinder
	include ActiveModel::Validations

	attr_accessor :source, :destination, :all_pairs_distances

	def initialize(source=0, destination=0)
		@source = source
		@destination = destination
	end

	# Different types of generations (src/dest, all-pairs, etc)
	def path_from_src_to_dest(graph, src=0, dest=0)
		# Update source and destination
		@source, @destination = src, dest

		# Check if source is undefined, if so return empty path
		if @source == 0
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
		paths_tracer, paths_distances, relationships_on_paths = compute_paths_from_source(outgoing, nodes)
		
		# Find the shortest path through the graph between source and destination
		if destination != 0
			return trace_path_src_to_dest(outgoing, paths_tracer)
		end

		# This happens only if the destination is 0, as it would have returned otherwise.
		# Return available relationships, distances, 
		return important_relationships_from_source(paths_tracer, paths_distances, relationships_on_paths)
	end

	def compute_paths_from_source(edges, nodes)
		# Inputs: outgoing edges of each vertex, vertex array
		
		# Initializations		
		inf = 1/0.0	
		distance = Hash.new()
		previous = Hash.new()

		nodes.each do |i|
			distance[i] = inf
			previous[i] = -1
		end

		distance[@source] = 0
		queue = nodes.compact

		# Find shortest paths
		while (queue.length > 0)
			# Check for accessible vertices
			u = nil
			queue.each do |min|
				if (not u) or (distance[min] and distance[min] < distance[u])
					u = min
				end
			end
			
			if (distance[u] == inf)
				break
			end

			# Check neighbors
			queue = queue - [u]
			edges[u].keys.each do |v|
				alt = distance[u] + 1 # Placeholder
				if alt < distance[v]
					distance[v] = alt
					previous[v] = u
				end
			end
		end

		return previous, distance, get_relationships_by_tracer(previous, edges)

	end

	def get_relationships_by_tracer(tracer, edges)
		# This method walks through a tracer (a list of "previous" nodes) by key,value,
		# adding the relationship id of each to an array which is then returned.
		# tracer[child] = parent
		# On the paths from source to all of its destinations, some relationship parent->child exists.
	
		relationships = Array.new		
		tracer.each do |key, value|
			if value != -1
				relationships << edges[value][key].id
			end
		end

		return relationships
	end

	def trace_path_src_to_dest(edges, tracer)
		# Computes path from destination to source

		path = {}
		current = @destination
		while tracer[current] != -1
			path [ edges[ tracer[current] ][ current ].id ] = false
			current = tracer[current]
		end

		# Check for source...

		return path
	end

	def important_relationships_from_source(tracer, distances, relationships)
		# This method limits paths from a source node by importance, so as to only
		# show the paths from a given source that are of the most "value" to a user.
		# First, a page-rank like importance score is computed for the entire graph.
		# Second, the resulting list of scores is filtered by relationships that already exist in this graph.
		# Third, the inverse of the distance squared ("gravity") is applied as a multiplier
		# 	to this ranking score. This way, well-connected nodes far from our source
		#	are not given an unfair advantage.
		# Finally, upon sorting this list by rank, the top 20 relationships are selected
		# 	and return in a map. The key of this map is the relationship ID, and its value
		#	is whether or not it is an expandable relationship (it is "true" if it is not connected to the source)

		# Initialize output paths
		important_paths = Hash.new()

		# Obtain ranking of all issues in graph
		ranking = compute_all_issues_rank()

		# Filter ranking by available relationships
		# This isn't the most graceful way to do this, might be fine with a select statement
		filtered_ranking = Hash.new()
		distances.each do |target, dist|
			if dist != 1/0.0 and dist != 0
				filtered_ranking[target] = ranking[target]
			end
		end

		# Apply gravity multiplier to each value in filtered ranking
		filtered_ranking.keys.each {|key| filtered_ranking[key] *= (1.0 / (distances[key]*distances[key])) }

		# Sort filtered ranking by gravity-adjusted ranking, descending
		sorted_ranking = filtered_ranking.sort {|a,b| -1*(a[1] <=> b[1]) }

		# Add each sorted ranking item to important paths, either to be expandable or not depending on its distance from source		
		sorted_ranking[1..20].each do |pair|
			to_expand = false
			if distances[ pair[0] ] > 1
				to_expand = true
			end
			important_paths[pair[0]] = to_expand
		end
		return important_paths
	end

	# Temporary fake ranking of 0.75 for everybody
	def compute_all_issues_rank
		issues = Issue.find :all
		ranking = Hash.new()
		issues.each {|i| ranking[i.id] = 0.75 }
		return ranking
	end

	def compute_all_pairs_paths(e, v)
		distances = Hash.new()

		v.each do |node|
			@source = node
			tmp1, distances[node], tmp2 = compute_paths_from_source(e, v)		
		end	

		return distances	
	end
end
