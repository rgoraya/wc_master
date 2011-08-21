class VersionsController < ApplicationController

	require 'thread'	
	@@mutex = Mutex.new
	

	def index
		@versions = Version.paginate :page => params[:page], :order => 'created_at DESC'
		respond_to do |format|
      		format.html # index.html.erb
      		format.xml  { render :xml => @versions }
    	end
	end

	def restore
		version = Version.find(params[:id])
		@@mutex.synchronize{ #mutex to ensure reverted_from is updated correctly
			count = version.sibling_versions.count
			version.revert
			if count < version.sibling_versions.count
				version.sibling_versions.last.update_attributes(:reverted_from=>version.id)
			end
		}
		respond_to do |format|
      		format.html {redirect_to(:back)}
      		format.xml
    	end

	end

end
