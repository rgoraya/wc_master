class VersionsController < ApplicationController
	@@mutex = Mutex.new
	require 'thread'	
	
	def index
		@versions = Version.paginate(:per_page => 10, :page => params[:page], :order => 'created_at DESC')
		respond_to do |format|
      		format.html # index.html.erb
      		format.xml  { render :xml => @versions }
    	end
	end

	def restore
		@@mutex.synchronize{ #mutex to ensure reverted_from is updated correctly
		count = Version.all.count
		version = Version.find(params[:id])
		if !version.event.eql?('create')
			version.reify.save
		else
			begin
				Kernel.const_get(version.item_type).find(version.item_id).destroy
			rescue ActiveRecord::RecordNotFound
			end
		end
		if Version.all.count > count
			version.sibling_versions.last.update_attribute(:reverted_from, version.id) #update_attributes doesn't work; refer to: http://stackoverflow.com/questions/6626376/rails3-activerecord-update-attributes-cant-save-foreign-key
			Reputation::Utils.reputation(:action=>version.sibling_versions.first.event.downcase.to_sym, \
																			:type=>version.sibling_versions.first.item_type.downcase.to_sym, \
																			:id=>version.sibling_versions.first.item_id.to_i, \
																			:me=>version.sibling_versions.first.whodunnit.to_i, \
																			:you=>version.get_object.user_id.to_i, \
																			:vid=>version.id, \
																			:undo=>true, \
																			:calculate=>true)

		end
		}

		respond_to do |format|
			#format.html {render :nothing=>true}
			format.html {redirect_to(:back)} #issue_versions_path(params[:issue_id]), :notice => "Changes reverted!")}
			format.xml {head :ok}
		end
	end

end
