class Version

	cattr_reader :per_page
	@@per_page = 5

	def get_object
		object = nil		
		if !self.event.eql?('destroy')
			begin
				object = Kernel.const_get(self.item_type).find(self.item_id)
				object = object.version_at(self.created_at)
			rescue ActiveRecord::RecordNotFound
				object = Version.find(:all, :conditions => ["item_type = ? AND item_id = ? AND event = 'destroy'", self.item_type, self.item_id]).last.reify.version_at(self.created_at)
				#object = Version.where("item_type = %{\"self.item_type\"} AND item_id = #{self.item_id} AND event = 'destroy'").last.reify.version_at(self.created_at)
			end
		else
			object = self.reify
		end
		return object
	end

end


