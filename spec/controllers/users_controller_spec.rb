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

      it "should not create an user" do
        lambda do
          post :create, :user => @attr       
        end.should_not change(User, :count)
      end

    end

    describe "success" do
      before(:each) do
        @attr = { :username => "Foo", :email => "foo@bar.com", :password => "foobar", 
          :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do 
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the index of relationships" do
        post :create, :user => @attr
        response.code.should == "302"
        response.should redirect_to relationships_path
      end

      #Currently RSpec does not support following redirects, so this is out
      #of the scope for it. Uncomment when RSpec supports redirect follows
      #it "should have a welcome message" do
      #  post :create, :user => @attr
      #  response.should have_selector('div#notice', 
      #                                :content => "Registration succesful.")
      #end

    end  

  end

end            
