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
					  return nil unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', options[:id]]).first).nil? 
					  relationship = v.get_object 
					  [relationship.issue_id, relationship.cause_id].each do |issue_id|
						  return nil unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Issue', issue_id]).first).nil? 
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
					  return nil unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Reference', options[:id]]).first).nil? 
					  relationship_id = v.get_object.relationship_id
					  return nil unless !(v = Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', relationship_id]).first).nil?					
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
