class FeedBacksController < ApplicationController
  
  # GET /feed_backs/new
  # GET /feed_backs/new.xml
  def new
    @feed_back = FeedBack.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feed_back }
    end
  end

  # POST /feed_backs
  # POST /feed_backs.xml
  def create
    @feed_back = FeedBack.new(params[:feed_back])

    respond_to do |format|
			if verify_recaptcha
      	if @feed_back.save
					ReportMailer.report(@feed_back).deliver
        	format.html { redirect_to( new_feed_back_path, :notice => 'Your feedback was successfully submitted. Thank you for your input.' )}
      	else
        	format.html {render :action=>"new"}
      	end
			else
				@feed_back.errors.clear["Captcha:"] = "invalid code"
				format.html {render :action=>"new"}
			end
    end
  end

end
