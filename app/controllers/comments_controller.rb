class CommentsController < ApplicationController
  def create
    @comment = Comment.new(params[:comment])
    @relationship = Relationship.find(@comment.relationship_id)

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

  def destroy
    @comment = Comment.find(params[:id])
    @relationship = Relationship.find(@comment.relationship_id)
    @comment.destroy

    Version.destroy_all(["item_type = ? AND item_id = ?", "Comment", @comment.id])

    @comnotice = "Comment Deleted!"
    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
      format.js
    end
  end

end
