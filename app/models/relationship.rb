class Relationship < ActiveRecord::Base
  
  # issues have an owner
  belongs_to :user
  
  belongs_to :issue
  belongs_to :cause,  :class_name => 'Issue', :foreign_key => 'cause_id'
  #belongs_to :effect, :class_name => 'Issue', :foreign_key => 'issue_id'

  has_many :references, :dependent => :destroy
	has_many :comments, :dependent => :destroy

  # validate uniqueness of the combination of Issue_ID, Cause_ID and Relationship_type
  validates :issue_id, :presence => true, :uniqueness => {:scope => [:cause_id, :relationship_type]}

  has_paper_trail :on=>[:create, :destroy]

def validate
  errors.add_to_base('Cannot be a cause/effect of itself!') if issue_id == cause_id 
end

end
