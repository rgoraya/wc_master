class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
	@src = 1
	@g = Graph.new
	@demo_type = ""

	### Demo ###
	if params[:demo] == 'all'
		@demo_type = "All Issues"
		@g.demo_all()
	elsif params[:demo] == 'original'
		@demo_type = "Original Issues"
		@g.get_graph_of_earliest()
	elsif params[:demo] == 'recent'
		@demo_type = "Most Recent Issues"
		@g.get_graph_of_most_recent()
	end	
  end

end
