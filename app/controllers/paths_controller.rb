class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
	@paths = Issue.order("created_at ASC").limit(40)
	@g = Graph.new

	
	
  end

end
