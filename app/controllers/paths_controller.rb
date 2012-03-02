class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
	@src = 1
	@g = Graph.new
	@demo_type = ""
	
	arr = Array.new
	arr << 47
	@g.get_graph_of_issue_neighbors(arr)		
  end

end
