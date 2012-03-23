class Relationship < ActiveRecord::Base
  
  # relationships have an owner
  belongs_to :user
  
  belongs_to :issue
  belongs_to :cause,  :class_name => 'Issue', :foreign_key => 'cause_id'

  # has many references and comments
  has_many :references
	has_many :comments

  # Gem for mainaining versions
  has_paper_trail :on=>[:create, :destroy]

  # Votes
  has_many :votes
  
  # Types of votes
  has_many :endorsements,  :through => :votes, :conditions => ['vote_type = "E"'], :order => 'votes.created_at DESC'  
  has_many :contestations, :through => :votes, :conditions => ['vote_type = "C"'], :order => 'votes.created_at DESC'  
  has_many :accusations,   :through => :votes, :conditions => ['vote_type = "A"'], :order => 'votes.created_at DESC'  
  # Types of voters
  has_many :endorsers,     :through => :votes, :conditions => ['vote_type = "E"'], :order => 'votes.created_at DESC'  
  has_many :contesters,    :through => :votes, :conditions => ['vote_type = "C"'], :order => 'votes.created_at DESC'  
  has_many :accusers,      :through => :votes, :conditions => ['vote_type = "A"'], :order => 'votes.created_at DESC' 

  # validate uniqueness of the combination of Issue_ID, Cause_ID and Relationship_type
  validates :issue_id, :presence => true, :uniqueness => {:scope => [:cause_id, :relationship_type]}

  # validate that issues cannot be cause/effect of themselves
  def validate
    errors.add_to_base('Cannot be a cause/effect of itself!') if issue_id == cause_id 
  end

end
