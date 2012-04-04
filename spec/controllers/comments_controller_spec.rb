require 'spec_helper'
require 'authlogic/test_case'

describe CommentsController do
  describe "POST 'create'" do
    before(:each) do
      @comment = { content: "Comment number one", relationship_id: 1 }
      request.env["HTTP_REFERER"] = "where_i_came_from" 
    end

    it "should redirect to back" do
      post :create, :comment => @comment
      response.should redirect_to("where_i_came_from")
    end

    it "should have a notice" do
      post :create, :comment => @comment
      flash[:notice].should =~ /successfully added/i
    end

    it "should assign this to a relationship" do
      post :create, :comment => @comment
      saved_comment = Relationship.find_by_id(@comment[:relationship_id]).comments.first
      saved_comment.content.should == @comment[:content]
    end

    describe "when not signed-in" do
      it "should create an anonymous user comment" do
        post :create, :comment => @comment
        saved_comment = Relationship.find_by_id(@comment[:relationship_id]).comments.first
        saved_comment.user_id.should == nil
      end
    end    

    describe "when signed-in" do
      before(:each) do
        :activate_authlogic
        user = FactoryGirl.build(:user)
        @user_id = user.id
        UserSession.create(user)
      end

      it "should create a comment with an username" do
        post :create, :comment => @comment
        saved_comment = Relationship.find_by_id(@comment[:relationship_id]).comments.first
        saved_comment.user_id.should == @user_id
      end
    end

    describe "DELETE 'destroy'" do
      before(:each) do
        FactoryGirl.create(:comment)
      end

      it "should redirect to comments_url" do
        delete :destroy, :id => 1
        response.should redirect_to(comments_url)
      end

      describe "when not signed-in" do
        it "should not let us delete any comment" do
        end
      end

      describe "when signed in" do
        before(:each) do
          :activate_authlogic
          user = FactoryGirl.build(:user)
          @user_id = user.id
          UserSession.create(user)
        end

        it "should let us delete our own comments" do
        end
      end
    end
  end
end
