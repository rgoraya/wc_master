require "spec_helper"

describe VotesController do
  describe "routing" do

    it "routes to #index" do
      get("/votes").should route_to("votes#index")
    end

    it "routes to #new" do
      get("/votes/new").should route_to("votes#new")
    end

    it "routes to #show" do
      get("/votes/1").should route_to("votes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/votes/1/edit").should route_to("votes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/votes").should route_to("votes#create")
    end

    it "routes to #update" do
      put("/votes/1").should route_to("votes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/votes/1").should route_to("votes#destroy", :id => "1")
    end

  end
end
