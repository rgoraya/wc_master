class VersionsController < ApplicationController
	
	def index
		@versions = Version.paginate :page => params[:page], :order => 'created_at DESC'
		#@versions = Version.all
		respond_to do |format|
      		format.html # index.html.erb
      		format.xml  { render :xml => @versions }
    	end
	end

	def restore
		version = Version.find(params[:id])
		if !version.event.eql?('create')
			version.reify.save
		else
			begin
				Kernel.const_get(version.item_type).find(version.item_id).destroy
			rescue ActiveRecord::RecordNotFound
			end
		end
		
		respond_to do |format|
			format.html {redirect_to(issue_versions_path(params[:issue_id]), :notice => "Changes reverted!")}
			format.xml {head :ok}
		end
	end

end
