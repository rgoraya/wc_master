require 'spec_helper'

describe VotesController do

  def valid_attributes
    {:relationship_id => "1", :vote_type => "1", :user_id =>"1"}
  end

  describe "GET index" do

    it "assigns all votes as @votes" do
      vote = Vote.create! valid_attributes
      get :index
      assigns(:votes).should eq([vote])
    end
  end

  describe "GET show" do
    it "assigns the requested vote as @vote" do
      vote = Vote.create! valid_attributes
      get :show, :id => vote.id
      assigns(:vote).should eq(vote)
    end
  end

  describe "GET new" do
    it "assigns a new vote as @vote" do
      get :new
      assigns(:vote).should be_a_new(Vote)
    end
  end

  describe "GET edit" do
    it "assigns the requested vote as @vote" do
      vote = Vote.create! valid_attributes
      get :edit, :id => vote.id
      assigns(:vote).should eq(vote)
    end
  end

  describe "POST create" do
    before(:each) do
      FactoryGirl.create(:relationship)
    end           

    describe "with valid params" do
      it "creates a new Vote" do
        expect {
          post :create, :vote => valid_attributes
        }.to change(Vote, :count).by(1)
      end

      it "assigns a newly created vote as @vote" do
        post :create, :vote => valid_attributes
        assigns(:vote).should be_a(Vote)
        assigns(:vote).should be_persisted
      end

      it "redirects to the created vote" do
        post :create, :vote => valid_attributes
        response.should redirect_to(Vote.last)
      end
    end

    describe "with invalid params" do
      it "re-renders the 'new' template" do
        Vote.any_instance.stub(:save).and_return(false)
        post :create, :vote => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested vote" do
        vote = Vote.create! valid_attributes
        # Assuming there are no other votes in the database, this
        # specifies that the Vote created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Vote.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => vote.id, :vote => {'these' => 'params'}
      end

      it "assigns the requested vote as @vote" do
        vote = Vote.create! valid_attributes
        put :update, :id => vote.id, :vote => valid_attributes
        assigns(:vote).should eq(vote)
      end

      it "redirects to the vote" do
        vote = Vote.create! valid_attributes
        put :update, :id => vote.id, :vote => valid_attributes
        response.should redirect_to(vote)
      end
    end

    describe "with invalid params" do
      it "assigns the vote as @vote" do
        vote = Vote.create! valid_attributes
        Vote.any_instance.stub(:save).and_return(false)
        put :update, :id => vote.id, :vote => {}
        assigns(:vote).should eq(vote)
      end

      it "re-renders the 'edit' template" do
        vote = Vote.create! valid_attributes
        Vote.any_instance.stub(:save).and_return(false)
        put :update, :id => vote.id, :vote => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      FactoryGirl.create(:relationship)
    end                

    it "destroys the requested vote" do
      vote = Vote.create! valid_attributes
      expect {
        delete :destroy, :id => vote.id
      }.to change(Vote, :count).by(-1)
    end

    it "redirects to the votes list" do
      vote = Vote.create! valid_attributes
      delete :destroy, :id => vote.id
      response.should redirect_to(votes_url)
    end
  end

end
