class Version

	cattr_reader :per_page
	@@per_page = 5

	belongs_to :user, :class_name=>'User', :foreign_key=>:whodunnit

	
	def get_object
		object = nil		
		if !self.event.eql?('destroy')
			begin
				object = Kernel.const_get(self.item_type).find(self.item_id)
				object = object.version_at(self.created_at + 0.000001.seconds)
			rescue ActiveRecord::RecordNotFound
				object = Version.find(:all, :conditions => ["item_type = ? AND item_id = ? AND event = 'destroy'", self.item_type, self.item_id]).last.reify.version_at(self.created_at)
			end
		else
			object = self.reify
		end
		return object
	end

	def revert
		if !self.event.eql?('create')
			self.reify.save
		else
			(model = Kernel.const_get(self.item_type)).exists?(self.item_id) ?  model.find(self.item_id).destroy : return
			#Version.find(:all, :conditions=>['item_type = ? AND item_id = ?', self.item_type, self.item_id]).map(&:item).uniq.destroy
		end

		#Version.find(:all, :conditions=>['item_type = ? AND item_id = ?', @ref.class.name, @ref.id].each do |v|
		#	v.destroy
		#end
		case self.item_type
			when 'Relationship'
				if self.event.eql?('destroy') #revert a 'destroy' == recreate this relationship
					Version.find(:all, :conditions=>['item_type = ?','Reference']).each do |version|
						if version.get_object.relationship_id == self.item_id
							version.revert
						end
					end
				end
				return
			when 'Reference'
				self.destroy
			else
				return
		end
	end
end


