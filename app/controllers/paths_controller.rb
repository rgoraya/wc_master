class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
	@paths = Issue.order("created_at ASC").limit(40)
	@src = 1
	@g = Graph.new

	if params[:demo] == 'all'

	elsif params[:demo] == 'original'

	elsif params[:demo] == 'recent'

	end	
  end

end
