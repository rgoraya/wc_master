require 'spec_helper'

describe UserSessionsController do
  render_views

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = { :username => "", :password => ""}
        request.env["HTTP_REFERER"] = "where_i_came_from"
      end    

      it "should redirect to back" do
        post :create, :session => @attr
        response.should redirect_to("where_i_came_from")
      end

      it "should have a notice message" do
        post :create, :session => @attr
        flash[:notice].should_not be_blank
      end
    end  

    describe "success" do
      before(:each) do
        @user = FactoryGirl.create(:user)  
        @attr = { :username => @user.username, :password => @user.password }
        request.env["HTTP_REFERER"] = "where_i_came_from"
      end
      
      it "should redirect to back" do
        post :create, :session => @attr
        response.should redirect_to("where_i_came_from")
      end

      # No need for more tests (it'd be testing Authlogic internals) 
    end
  end
end       
