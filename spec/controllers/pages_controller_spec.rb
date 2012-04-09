require 'spec_helper'

describe PagesController do
  render_views

  describe "GET 'home'" do
    it "returns http success" do
      get :home
      response.should be_success
    end    

    it "should have the right title" do
      get :home  
      response.should have_selector("title", 
                                    :content => "Welcome to Causality Project")
    end

    it "should have a non-blank body" do
      get :home
      response.body.should_not =~ /<body>\s*<\/body>/     
    end
  end

  describe "GET 'contact'" do
    it "should redirect to feedback/new" do
      get :contact
      response.should redirect_to('/feed_backs/new')
    end
  end

end
