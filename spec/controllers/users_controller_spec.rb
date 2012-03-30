require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "returns http success" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user    #:user is the one at the controller
    end      

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.username )
    end 

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector('a>img', :class => "gravatar" )
    end

    it "should lead us to our gravatar profile or signup page" do
      get :show, :id => @user
      response.should have_selector('a', :href => "https://en.gravatar.com/emails")
    end

  end

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

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr =  { :username => "", :email => "", :password => "", 
                  :password_confirmation => "" }   
      end

      it "should render the 'new' page" do
        post :create, :user => @attr       
        response.code.should == "200"
        response.should render_template('new')
      end
    end
    
  end

end            
