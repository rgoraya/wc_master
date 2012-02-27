require 'spec_helper'

describe "votes/show.html.haml" do
  before(:each) do
    @vote = assign(:vote, stub_model(Vote,
      :user_id => "User",
      :relationship_id => "Relationship",
      :vote_type => "Vote Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/User/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Relationship/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Vote Type/)
  end
end
