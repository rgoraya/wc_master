class PagesController < ApplicationController
  def home
  end

  def contact
		@feedback = FeedBack.new
		
		respond_to do |format|
			format.html
		end
  end

  def about
  end

	def stats
	end

end
