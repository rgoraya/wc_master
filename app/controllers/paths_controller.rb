class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
	@paths = Issue.order("created_at ASC").limit(5)
	@src = 1
	@g = Graph.new

	### Demo ###
	if params[:demo] == 'all'
		@g.demo_all()
	elsif params[:demo] == 'original'
		@g.get_graph_of_earliest()
	elsif params[:demo] == 'recent'
		@g.get_graph_of_most_recent()
	end	
  end

end
