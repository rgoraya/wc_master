class PathsController < ApplicationController
  # GET /paths
  # GET /paths.xml
  def index
    @paths = Issue.order("created_at DESC").paginate(:per_page => 20, :page => params[:page])

    respond_to do |format|
      render :nothing => true
    end
  end

end
