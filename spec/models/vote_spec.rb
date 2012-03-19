require 'spec_helper'

describe Vote do
 
  before(:each) do 
    @vote = Vote.new(:relationship_id=> "1", :vote_type => "1", :user_id => "1")
  end

  it "should be valid when new" do
    @vote.should be_valid
  end

  it "should not be valid if missing relationship_id" do
    @vote.relationship_id = ''
    @vote.should_not be_valid
  end

  it "should not be valid if missing vote_type" do
    @vote.vote_type = ""
    @vote.should_not be_valid
  end

  it "should change after an user votes twice" do
    @vote.should be_valid
    second_vote = Vote.new(:relationship_id=> "1", :vote_type => "0", :user_id => "1") 
    second_vote.save.should == true
    Vote.find_by_user_id("1").vote_type.should == "0"
  end
end

