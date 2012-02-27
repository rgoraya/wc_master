class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
	@paths = Issue.order("created_at DESC").limit(40)

  end

end
