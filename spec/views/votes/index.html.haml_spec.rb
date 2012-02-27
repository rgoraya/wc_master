require 'spec_helper'

describe "votes/index.html.haml" do
  before(:each) do
    assign(:votes, [
      stub_model(Vote,
        :user_id => "User",
        :relationship_id => "Relationship",
        :vote_type => "Vote Type"
      ),
      stub_model(Vote,
        :user_id => "User",
        :relationship_id => "Relationship",
        :vote_type => "Vote Type"
      )
    ])
  end

  it "renders a list of votes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "User".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Relationship".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Vote Type".to_s, :count => 2
  end
end
