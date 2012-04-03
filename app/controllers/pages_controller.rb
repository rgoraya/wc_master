class PagesController < ApplicationController
  
  layout 'pages'
  
  def home
  end

  def contact
		redirect_to :controller => 'feed_backs', :action => 'new'
  end

  def about
  end

	def stats
	end

end
