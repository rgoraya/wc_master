require 'spec_helper'

describe "games/new" do
  before(:each) do
    assign(:game, stub_model(Game).as_new_record)
  end

  it "renders new game form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => games_path, :method => "post" do
    end
  end
end
