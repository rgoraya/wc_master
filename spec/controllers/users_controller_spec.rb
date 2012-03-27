require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do
    it "returns http success" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector('div', :class   => 'pageheading',
                                           :content => 'Register as a new user')
    end
  end

end            
