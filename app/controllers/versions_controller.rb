class VersionsController < ApplicationController
	
	
	def index
		@versions = Version.paginate(:per_page => 10, :page => params[:page], :order => 'created_at DESC')
		respond_to do |format|
      		format.html # index.html.erb
      		format.xml  { render :xml => @versions }
    	end
	end

	def restore 
		version = Version.find(params[:id])
		version.restore

		respond_to do |format|
			#format.html {render :nothing=>true}
			format.html {redirect_to(:back)} #issue_versions_path(params[:issue_id]), :notice => "Changes reverted!")}
			format.xml {head :ok}
		end
	end

end
