require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do
    it "should redirect_to the home page" do
      get :index
      response.should redirect_to(issues_path)
    end
  end

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
    
    describe "contributions" do
      it "should show the user's reputation" do
        get :show, :id => @user
        response.should have_selector('div.reputation_block', 
                                      :content => @user.reputation.to_s)
      end

      it "should show the number of issues created" do
        get :show, :id => @user
        issues_created = Version.find(:all, 
                                      :conditions=>['item_type=? AND event=? 
                                      AND whodunnit=? AND reverted_from IS ?', 
                                      'Issue', 'create', @user.id, nil]).
                                      map(&:item_id).uniq.count 

        response.should have_selector('div',
                                      :class   => "issues_created",
                                      :content => issues_created.to_s )
      end

      it "should show the number of issues removed" do
        get :show, :id => @user
        issues_deleted = Version.find(:all, 
                                      :conditions=>['item_type=? AND event=? 
                                      AND whodunnit=? AND reverted_from IS ?', 
                                      'Issue', 'delete', @user.id, nil]).
                                      map(&:item_id).uniq.count 

        response.should have_selector('div',
                                      :class   => "issues_deleted",
                                      :content => issues_deleted.to_s )
      end

      it "should show the number of current issues" do
        get :show, :id => @user
        current_issues = @user.issues.count
        response.should have_selector('div',
                                      :class   => "current_issues",
                                      :content => current_issues.to_s )
      end

      it "should show the number of current relations" do
        get :show, :id => @user
        current_relationships = @user.relationships.count
        response.should have_selector('div',
                                      :class   => "current_relations",
                                      :content => current_relationships.to_s )
      end  

      it "should show the number of references" do
        get :show, :id => @user
        current_references = @user.references.count
        response.should have_selector('div',
                                      :class   => "references",
                                      :content => current_references.to_s )
      end  
                          
      it "should show the number of issues created" do
        get :show, :id => @user
        relationships_created = Version.find(:all, 
                                      :conditions=>['item_type=? AND event=? 
                                      AND whodunnit=? AND reverted_from IS ?', 
                                      'Relationship', 'create', @user.id, nil]).
                                      map(&:item_id).uniq.count 

        response.should have_selector('div',
                                      :class   => "relations_connected",
                                      :content => relationships_created.to_s )
      end                 

      it "should show the number of relationships removed" do
        get :show, :id => @user
        relationships_deleted = Version.find(:all, 
                                      :conditions=>['item_type=? AND event=? 
                                      AND whodunnit=? AND reverted_from IS ?', 
                                      'Relationship', 'delete', @user.id, nil]).
                                      map(&:item_id).uniq.count 

        response.should have_selector('div',
                                      :class   => "relations_deleted",
                                      :content => relationships_deleted.to_s )
      end
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

  describe "PUT 'update'" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end    

    describe "failure" do
      before(:each) do
        @attr = { :username => "", :email => "", :password => "", 
          :password_confirmation => "" }
      end 

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :username => "RedFoo", :email => "foo@br.com", :password => "foobar", 
          :password_confirmation => "foobar" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.username.should == user.username
        @user.email.should == user.email
      end

      it "should redirect_to relationships" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(relationships_path)
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:notice].should =~ /Successfully updated profile/i
      end
    end      
  end

end            
