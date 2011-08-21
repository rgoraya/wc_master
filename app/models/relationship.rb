class Relationship < ActiveRecord::Base
  belongs_to :issue
  belongs_to :cause, :class_name => 'Issue', :foreign_key => 'cause_id'

  has_many :references, :dependent => :destroy

  belongs_to :user
  #validates :user_id, :presence => true

  validates :cause_id, :uniqueness => {:scope => :issue_id}
  has_paper_trail 

def validate
  errors.add_to_base('Cannot be a cause/effect of itself!') if issue_id == cause_id
end

end
