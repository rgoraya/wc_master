class FeedBack < ActiveRecord::Base
	validates :subject, :presence=>true
	validates :description, :presence=>true
	validates :category, :presence=>true	#0 is suggestion, 1 is bug
	belongs_to :user

end
