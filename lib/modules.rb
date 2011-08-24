module RepManagement
	
	
	module Utils
		@@mutex = Mutex.new

		def self.reputation(options={})
		  begin
			  unless (!options.empty? &&
					  (options.keys - [:action, :type, :id, :me, :you, :calculate]).empty? &&
					  [:create, :destroy, :up, :down].include?(options[:action].to_sym) && 
					  [:relationship, :issue, :reference].include?(options[:type].to_sym) &&
					  [true, false].include?(options[:calculate])
					  )
				  raise ArgumentError, 'Missing or invalid argument :action :type :calculate'
			  end
			  
			  score = [0,0]
			  ids = []

			  case [options[:action],options[:type]]
				  when [:create, :relationship]
					  raise ArgumentError, "Missing or invalid argument :id :me" unless (!options[:id].nil? && options[:id].integer?) && (!options[:me].nil? && options[:me].integer?)

					  degree = 3
					  return false unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', options[:id]]).first).nil? 
					  relationship = v.get_object 
					  [relationship.issue_id, relationship.cause_id].each do |issue_id|
						  return false unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Issue', issue_id]).first).nil? 
						  if ((user_id = v.get_object.user_id) == options[:me])
							  degree -= 1
						  else
							  ids << user_id
						  end
					  end
					  case degree
						  when 1 then score = [0,0] #both issues are yours
						  when 2 then score = [2,1] #one of them is yours
						  when 3 then score = [4,2] #none of them is yours
					  end

				  when [:destroy, :relationship]
					  raise ArgumentError, "Missing or invalid argument :id :me :you" unless (!options[:id].nil? && options[:id].integer?) && (!options[:me].nil? && options[:me].integer?) && (!options[:you].nil? && options[:you].integer?)

					  ids << options[:you]

				  when [:create, :issue]
					  raise ArgumentError, "Missing or invalid argument :me" unless !options[:me].nil? && options[:me].integer?
					  score = [0,0]

				  when [:destroy, :issue]
					  raise ArgumentError, "Missing or invalid argument :id :me :you" unless (!options[:me].nil? && options[:me].integer?) && (!options[:you].nil? && options[:you].integer?) && (!options[:id].nil? && options[:id].integer?)
					  ids << options[:you]			

				  when [:create, :reference]
					  raise ArgumentError, "Missing or invalid argument :id :me" unless (!options[:id].nil? && options[:id].integer?) && (!options[:me].nil? && options[:me].integer?)

					  degree = 2
					  return false unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Reference', options[:id]]).first).nil? 
					  relationship_id = v.get_object.relationship_id
					  return false unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', relationship_id]).first).nil?					
					  (user_id = v.get_object.user_id) == options[:me] ? degree -= 1 : ids << user_id
					  case degree
						  when 1 then score = [1,0] #ref on a your rel
						  when 2 then score = [3,2] #ref on other's rel
					  end

				  when [:destroy, :reference]
					  raise ArgumentError, "Missing or invalid argument :id :me :you" unless (!options[:id].nil? && options[:id].integer?) && (!options[:me].nil? && options[:me].integer?) && (!options[:you].nil? && options[:you].integer?)
					  ids << options[:you]

				  when [:up, :relationship]
					  raise ArgumentError, "Missing or invalid argument :id :me :you" unless (!options[:id].nil? && options[:id].integer?) && (!options[:me].nil? && options[:me].integer?) && (!options[:you].nil? && options[:you].integer?)


				  when [:down, :relationship]
					  raise ArgumentError, "Missing or invalid argument :id :me :you" unless (!options[:id].nil? && options[:id].integer?) && (!options[:me].nil? && options[:me].integer?) && (!options[:you].nil? && options[:you].integer?)

				  else
					  score = [0,0]
			  end
				  
			  if options[:calculate]
				  @@mutex.synchronize{
					  mine = ((me = User.find(options[:me])).reputation += score[0])
					  (mine < 1) ? me.update_attributes(:reputation=>1) : me.update_attributes(:reputation=>mine)
				  
					  ids.each do |id|
						  yours = ((you = User.find(id)).reputation += score[1])
					  	(yours < 1) ? you.update_attributes(:reputation=>1) : you.update_attributes(:reputation=>yours)
					  end
					  return true
				  }
			  else
				  return score
			  end
		  rescue
		    return false
		  end
		end

	end

	module ClassMethods
	end

	module InstanceMethods
	end
end


module Maintenance
	
	module Utils
		
		#help 'cure' inconsistent database between versioning deployment & repmanagement deployment
		#run once only
		def self.make_consistent
			Issue.all.each do |issue|
				if Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Issue', issue.id]).empty?
					Version.create(:item_type=>'Issue', :item_id=>issue.id, :event=>'create', :whodunnit=>issue.user_id, :object=>nil, :created_at=>issue.updated_at, :reverted_from=>nil)
					#RepManagement::Utils.reputation(:action=>:create, :type=>:issue, :me=>issue.user_id, :calculate=>true)
				end					
			end
			#sleep 2
			#Version.find(:all, :conditions=>["created_at<?", DateTime.now]).each do |version|
				#RepManagement::Utils.reputation(:action=>version.event.downcase.to_sym, :type=>version.item_type.downcase.to_sym, :id=>version.item_id.to_i, :me=>version.whodunnit.to_i, :you=>version.get_object.user_id.to_i, :calculate=>true)
			#end
			Version.find(:all,:conditions=>["item_type=?", 'Relationship']).each do |version|
				if version.event.eql?('create')
					if Relationship.exists?(version.item_id)
						Relationship.paper_trail_off
						Relationship.find(version.item_id).update_attributes(:user_id=>version.whodunnit)
						Relationship.paper_trail_on
					else
						Version.find(:all, :conditions=>['item_type=? AND item_id=? AND event != ?', 'Relationship', version.item_id, 'create']).each do |v|
							!(o = v.object).include?('user_id') ? v.update_attributes(:object=>o+"user_id: #{version.whodunnit.to_s}\n") : v.update_attributes(:object=>o.gsub(/user_id\:/,"user_id: #{version.whodunnit.to_s}"))
						end
					end
				end
			end
		end

		def self.recalculate
			User.all.each do |user|
				user.update_attributes(:reputation=>1)
			end
			Version.all.each do |version|
				RepManagement::Utils.reputation(:action=>version.event.downcase.to_sym, :type=>version.item_type.downcase.to_sym, :id=>version.item_id.to_i, :me=>version.whodunnit.to_i, :you=>version.get_object.user_id.to_i, :calculate=>true)
			end
		end
	end


end

