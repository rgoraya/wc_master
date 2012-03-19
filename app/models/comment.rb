class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :relationship

  validates :content, :presence => {:message => 'Please enter your comment!'}
  validates_length_of :content, :within => 1..1000000
  validates :relationship_id, :presence => true
  validates_numericality_of :relationship_id, :message => "Error saving comment"

  has_paper_trail :on=>[:create, :destroy]

end
