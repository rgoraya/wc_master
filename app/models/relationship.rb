class Relationship < ActiveRecord::Base
  
  belongs_to :user
  
  belongs_to :issue
  belongs_to :cause,  :class_name => 'Issue', :foreign_key => 'cause_id'

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
  validate :issue_different_to_cause

  # validate that issues cannot be cause/effect of themselves
  def issue_different_to_cause
    errors.add_to_base('Cannot be a cause/effect of itself!') if issue_id == cause_id 
  end

end
# == Schema Information
#
# Table name: relationships
#
#  id                :integer         not null, primary key
#  issue_id          :integer
#  cause_id          :integer
#  created_at        :datetime
#  updated_at        :datetime
#  relationship_type :string(255)
#  references_count  :integer         default(0)
#  user_id           :integer
#

