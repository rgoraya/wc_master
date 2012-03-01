class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
	@src = 1
	@g = Graph.new
	@demo_type = ""

	@g.get_graph_of_most_cited(40)		
  end

end
