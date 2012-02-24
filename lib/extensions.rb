class Version

	@@mutex = Mutex.new
	require 'thread'

	cattr_reader :per_page
	@@per_page = 5

	belongs_to :user, :class_name=>'User', :foreign_key=>:whodunnit

	
	def get_object	
		if !self.event.eql?('destroy')
			if self.next
				return self.next.reify
			else
				return Kernel.const_get(self.item_type).find(self.item_id)
			end
		else
			return self.reify
		end
	end

	def restore
	
		#restore relationships
		#notes: if an issue/relationship exists and the same issue/relationship is re-created as the result of restoring a version, the latter is ignored.
		#for example, consider the sequense: create issue A (new action), remove issue A (revert), create issue A (new action), re-create issue A (by reverting removal) --> the last action takes no effect.
	
		#precondition for this function (as well as version history system) to work: changes to issues, relationships, references *must* only be recorded at "create" or "destroy" events.

		@@mutex.synchronize{ #mutex to ensure reverted_from is updated correctly
		count = Version.all.count
		if !self.event.eql?('create')
			rel = self.reify
			rel.save

			if self.item_type.eql?("Relationship")
				Version.find(:all, :conditions=>["item_type = ? AND event = ?", "Comment", "destroy"]).each do |v|
					if v.get_object.relationship_id == rel.id
						v.reify.save 
						Version.destroy_all(["item_type = ? AND item_id = ? AND id > ?", "Comment", v.item_id, v.sibling_versions.first]) #why keep multiple 'destroy' events of a comment? I just need the lastest to revert back.
					end
				end
				Version.find(:all, :conditions=>["item_type = ? AND event = ?", "Reference", "destroy"]).each do |v|
					if v.get_object.relationship_id == rel.id
						v.reify.save
						Version.destroy_all(["item_type = ? AND item_id = ? AND id > ?", "Reference", v.item_id, v.sibling_versions.first])
					end
				end
			end
		else
			begin
				Kernel.const_get(self.item_type).find(self.item_id).destroy
			rescue ActiveRecord::RecordNotFound
			end
		end



		if Version.all.count > count #undo is successful and a new 'version' is created
			self.sibling_versions.last.update_attribute(:reverted_from, self.id) #update_attributes doesn't work; refer to: http://stackoverflow.com/questions/6626376/rails3-activerecord-update-attributes-cant-save-foreign-key
		
			#the point of doing "sibling_versions.first" is to ensure subsequent reverts (revert chain) grant reputation score correctly to rightful owners.
			#for example, a revert chain could potentially look like this: create(1 - new action), destroy(2 - from 1), create (3 - from 2), destroy (4 - from 1), create (5 - from 2). Since any registered user can do reverts, reputation points must be calculated carefully so that the person who originally creates the first version (also the person who create an issue/relationship) receives the right amount of reputation points, in the following manner:
			#		Original creation of an issue/relationship by user A: user A receives an amount of points.
			#		Any subsequent successful reverts by a random user B: user B gains no point, user A gains the opposite amount of points granted by the version being reverted.
			#		For example: create (A:gain +5), destroy (revert from 1; B:gain 0; A:gain -5), create(revert from 2; C:gain 0; A:gain +5), destroy(revert from 1; D:gain 0; A:gain -5)

			Reputation::Utils.reputation(:action=>self.sibling_versions.first.event.downcase.to_sym, \
																			:type=>self.sibling_versions.first.item_type.downcase.to_sym, \
																			:id=>self.sibling_versions.first.item_id.to_i, \
																			:me=>self.sibling_versions.first.whodunnit.to_i, \
																			:you=>self.get_object.user_id.to_i, \
																			:vid=>self.id, \
																			:undo=>true, \
																			:calculate=>true)

		end
		}


	end
end


