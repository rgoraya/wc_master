require 'spec_helper'

describe "votes/new.html.haml" do
  before(:each) do
    assign(:vote, stub_model(Vote,
      :user_id => "MyString",
      :relationship_id => "MyString",
      :vote_type => "MyString"
    ).as_new_record)
  end

  it "renders new vote form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => votes_path, :method => "post" do
      assert_select "input#vote_user_id", :name => "vote[user_id]"
      assert_select "input#vote_relationship_id", :name => "vote[relationship_id]"
      assert_select "input#vote_vote_type", :name => "vote[vote_type]"
    end
  end
end
