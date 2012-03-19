class Vote < ActiveRecord::Base

  belongs_to :user
  belongs_to :relationship
  
  # Vote types
  belongs_to :endorsement,  :class_name => 'Relationship', :foreign_key => 'relationship_id'
  belongs_to :contestation, :class_name => 'Relationship', :foreign_key => 'relationship_id'
  belongs_to :accusation,   :class_name => 'Relationship', :foreign_key => 'relationship_id'
  
  # Voters
  belongs_to :accuser,   :class_name => 'User', :foreign_key => 'user_id'  
  belongs_to :endorser,  :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :contester, :class_name => 'User', :foreign_key => 'user_id'

  # validate uniqueness of the combination of relationship_id and user_is
  validates :relationship_id, :presence => true, :uniqueness => {:scope => [:user_id]}
  validates :vote_type, :presence => true

end
