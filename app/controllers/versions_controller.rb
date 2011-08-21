class VersionsController < ApplicationController
	
	require 'thread'	
	
	def index
		@versions = Version.paginate :page => params[:page], :order => 'created_at DESC'
		respond_to do |format|
      		format.html # index.html.erb
      		format.xml  { render :xml => @versions }
    	end
	end

	def restore
		Mutex.new.synchronize{ #mutex to ensure reverted_from is updated correctly
		version = Version.find(params[:id])
		if !version.event.eql?('create')
			version.reify.save
		else
			begin
				Kernel.const_get(version.item_type).find(version.item_id).destroy
			rescue ActiveRecord::RecordNotFound
			end
		end
		Version.find(:all, :conditions => ["item_id = ? AND item_type = 'Relationship'", version.item_id], :order => 'created_at DESC').first.update_attributes(:reverted_from => version.id.to_s)
		}

		respond_to do |format|
			format.html {redirect_to(:back)} #issue_versions_path(params[:issue_id]), :notice => "Changes reverted!")}
			format.xml {head :ok}
		end
	end

end
