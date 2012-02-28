class User < ActiveRecord::Base
  require 'backports'
  
  # following code makes the user model to work as AUTHLOGIC authentication class
  acts_as_authentic

	has_many :activities, :class_name=>'Version', :foreign_key=>:whodunnit
	has_many :contributions, :class_name=>'Version', :foreign_key=>:whodunnit, :conditions=>['reverted_from IS ? AND NOT(item_type = ?)', nil, 'Suggestion']
	has_many :reverts, :class_name=>'Version', :foreign_key=>:whodunnit, :conditions=>['reverted_from IS NOT ? AND NOT(item_type = ?)',nil, 'Suggestion']

  has_many :issues
  has_many :relationships
  has_many :references

	has_many :feedbacks

  has_many :votes
  # all relationships the user endorses
  has_many :endorsed_relationships, :through => :votes, :source => :relationship, :conditions => ['vote_type = "E"']
  # all relationships the user contests
  has_many :contested_relationships, :through => :votes, :source => :relationship, :conditions => ['vote_type = "C"']


  # search functionality
  def self.search(search)
    if search
      where('title LIKE ?', "%#{search}%")
    else
      scoped
    end
  end



  def formatted(contrib)

    version = contrib

      activity={}
      #action type what time owner score
      activity[:type]=version.item_type
      activity[:time]=version.created_at
      (version.get_object.attributes.has_key?("user_id") && !version.get_object.user_id.nil?) ? activity[:owner]=version.get_object.user : activity[:owner]=nil

      case version.item_type
        when 'Issue'
          case version.event
            when 'create' 
              activity[:action]='Created'
              activity[:icon_position]='0px 0px'
            when 'update' 
              activity[:action]='Updated'
              activity[:icon_position]='-40px 0px'
            when 'destroy' 
              activity[:action]='Deleted'
              activity[:icon_position]='-20px 0px'
          end
          activity[:what]=version.get_object.title

        when 'Relationship'
          case version.event
            when 'create' 
              activity[:action]='Linked'
              activity[:icon_position]='0px -20px'
            when 'update' 
              activity[:action]='Updated'
              activity[:icon_position]='-40px -20px'
            when 'destroy' 
              activity[:action]='Removed'
              activity[:icon_position]='-20px -20px'
          end
          cause_version=Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', version.get_object.cause_id]).first
          issue_version=Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', version.get_object.issue_id]).first
          if cause_version.nil? || issue_version.nil?
            activity[:what]='? (data untraceable)'
          else
            activity[:what]=cause_version.get_object.title + ' &#9658; ' + issue_version.get_object.title
          end
        
          case version.get_object.relationship_type
            when 'I' then activity[:what] += ' (Inhibitory)'
            when 'H' then activity[:what] += ' (Set)'
            when nil then activity[:what] += ' (Causal)'
          end

        when 'Reference'
          case version.event
            when 'create' 
              activity[:action]='Added'
              activity[:icon_position]='0px -60px'
            when 'update' 
              activity[:action]='Updated'
              activity[:icon_position]='-40px -60px'
            when 'destroy' 
              activity[:action]='Deleted'
              activity[:icon_position]='-20px -60px'
          end
          relationship_version=Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', version.get_object.relationship_id]).first
          if relationship_version.nil?
            activity[:what]='? (data untraceable)'
          else
          	cause_version=Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', relationship_version.get_object.cause_id]).first
          	issue_version=Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', relationship_version.get_object.issue_id]).first
          	if cause_version.nil? || issue_version.nil?
            	activity[:what]='? (data untraceable)'
          	else
            	activity[:what]=cause_version.get_object.title + ' &#9658; ' + issue_version.get_object.title
          	end

          	case relationship_version.get_object.relationship_type
            	when 'I' then activity[:what] += ' (Inhibitory)'
            	when 'H' then activity[:what] += ' (Set)'
            	when nil then activity[:what] += ' (Causal)'
          	end
					end

        when 'Suggestion'
          case version.event
            when 'create' 
              activity[:action]='Created'
              activity[:icon_position]='0px -40px'
            when 'update' 
              ((version.reify.status.eql?('N') && version.get_object.status.eql?('D')) ? activity[:action]='Rejected' : activity[:action]='Updated')
              activity[:icon_position]='-20px -40px'
            when 'destroy' 
              activity[:action]='Deleted'
              activity[:icon_position]='-40px -40px'
          end
          activity[:what]=version.get_object.title

				when 'Comment'
					activity[:type] = 'on'
          case version.event
            when 'create' 
              activity[:action]='Commented'
              activity[:icon_position]='0px -80px'
            when 'destroy' 
              activity[:action]='Deleted comment'
              activity[:icon_position]='-40px -80px'
          end
          relationship_version=Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', version.get_object.relationship_id]).first
          if relationship_version.nil?
            activity[:what]='? (data untraceable)'
          else
          	cause_version=Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', relationship_version.get_object.cause_id]).first
          	issue_version=Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', relationship_version.get_object.issue_id]).first
          	if cause_version.nil? || issue_version.nil?
            	activity[:what]='? (data untraceable)'
          	else
            	activity[:what]=cause_version.get_object.title + ' &#9658; ' + issue_version.get_object.title
          	end

          	case relationship_version.get_object.relationship_type
            	when 'I' then activity[:what] += ' (Inhibitory)'
            	when 'H' then activity[:what] += ' (Set)'
            	when nil then activity[:what] += ' (Causal)'
          	end
					end

      end #case item_type

			activity[:score] = nil

			#since we don't show the score in the activity table, let's skip this function call
      #!activity[:what].include?('untraceable') ? activity[:score]= \
      #    Reputation::Utils.reputation(:action=>version.event.downcase.to_sym, \
      #    :type=>version.item_type.downcase.to_sym, \
      #    :id=>version.item_id.to_i, \
      #    :me=>version.whodunnit.to_i, \
      #    :you=>(version.get_object.attributes.has_key?("user_id") ? version.get_object.user_id.to_i : nil), \
      #    :undo=>false, \
      #    :calculate=>false)[0] : activity[:score]=nil

    
    return activity

  end




end
