class FeedBack < ActiveRecord::Base
	validates :subject, :presence=>true
	validates :description, :presence=>true
	validates :category, :presence=>true	#0 is suggestion, 1 is bug
	belongs_to :user

end
# == Schema Information
#
# Table name: feed_backs
#
#  id          :integer         not null, primary key
#  subject     :string(255)
#  description :string(255)
#  email       :string(255)
#  user_id     :integer
#  category    :integer
#  created_at  :datetime
#  updated_at  :datetime
#

