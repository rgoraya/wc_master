require 'spec_helper'

describe "votes/edit.html.haml" do
  before(:each) do
    @vote = assign(:vote, stub_model(Vote,
      :user_id => "MyString",
      :relationship_id => "MyString",
      :vote_type => "MyString"
    ))
  end

  it "renders the edit vote form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => votes_path(@vote), :method => "post" do
      assert_select "input#vote_user_id", :name => "vote[user_id]"
      assert_select "input#vote_relationship_id", :name => "vote[relationship_id]"
      assert_select "input#vote_vote_type", :name => "vote[vote_type]"
    end
  end
end
