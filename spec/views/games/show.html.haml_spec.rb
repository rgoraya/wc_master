require 'spec_helper'

describe "games/show" do
  before(:each) do
    @game = assign(:game, stub_model(Game))
  end

  it "renders attributes in <p>" do
    render
  end
end
