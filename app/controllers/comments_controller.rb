class CommentsController < ApplicationController

	def create
		@comment = Comment.new(params[:comment])
    
    respond_to do |format|
			if @comment.save
				format.html { redirect_to(:back, :notice => 'Comment was successfully added.') }
				format.xml  { render :xml => @comment, :status => :created, :location => @comment }
				format.js
			else
				@notice = @comment.errors
				format.html { redirect_to(:back, :notice => @comment.errors) }
				format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
				format.js
      end
    end
	end

end
