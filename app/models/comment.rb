class Comment < ActiveRecord::Base

	
	belongs_to :user
	belongs_to :relationship

	validates :content, :presence => {:message => 'Please enter your comment!'}
	validates :relationship_id, :presence => true

	has_paper_trail :on=>[:create, :destroy]

end
