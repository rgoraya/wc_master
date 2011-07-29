class Relationship < ActiveRecord::Base
  belongs_to :issue
  belongs_to :cause, :class_name => 'Issue', :foreign_key => 'cause_id'

def validate
  errors.add_to_base('Cannot be a cause/effect of itself!') if issue_id == cause_id
end

end
