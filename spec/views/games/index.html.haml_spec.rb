require 'spec_helper'

describe "games/index" do
  before(:each) do
    assign(:games, [
      stub_model(Game),
      stub_model(Game)
    ])
  end

  it "renders a list of games" do
    render
  end
end
