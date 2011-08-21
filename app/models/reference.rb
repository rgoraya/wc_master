class Reference < ActiveRecord::Base

	belongs_to :relationship
	
	belongs_to :user
	#validates :user_id, :presence => true

	has_paper_trail 

end
