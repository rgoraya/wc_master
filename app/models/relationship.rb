class Relationship < ActiveRecord::Base
  
  # issues have an owner
  belongs_to :user
  
  belongs_to :issue
  belongs_to :cause,  :class_name => 'Issue', :foreign_key => 'cause_id'
  #belongs_to :effect, :class_name => 'Issue', :foreign_key => 'issue_id'

  has_many :references
	has_many :comments

  # validate uniqueness of the combination of Issue_ID, Cause_ID and Relationship_type
  validates :issue_id, :presence => true, :uniqueness => {:scope => [:cause_id, :relationship_type]}

  has_paper_trail :on=>[:create, :destroy]

  has_many :votes
  has_many :endorsements, :through => :votes, :conditions => ['vote_type = "E"'], :order => 'votes.created_at DESC'  
  has_many :contestations, :through => :votes, :conditions => ['vote_type = "C"'], :order => 'votes.created_at DESC'  

  has_many :endorsers, :through => :votes, :conditions => ['vote_type = "E"'], :order => 'votes.created_at DESC'  
  has_many :contesters, :through => :votes, :conditions => ['vote_type = "C"'], :order => 'votes.created_at DESC'  



def validate
  errors.add_to_base('Cannot be a cause/effect of itself!') if issue_id == cause_id 
end

end
