require 'spec_helper'

describe "LayoutLinks" do

  it "should have a welcome page at '/'" do 
    get '/'
    response.should have_selector('title', :content=>"Welcome to Causality Project")
  end

  it "should have an issues index at '/issues'" do 
    get '/issues'
    response.should have_selector('title', :content=>"Causality Project: Issues")
  end

  it "should have a relationships index at '/relationships'" do 
    get '/relationships'
    response.should have_selector('title', :content=>"Causality Project: Relationships")
  end

  it "should have a new relationship creation assistant at /issues/new" do 
    get '/issues/new'
    response.should have_selector('title', :content=>"New Relationship")
  end

  it "should have a signup page at '/signup'" do
    get '/signup'                                      
    response.should have_selector('div[class="pageheading"]', :content => "Register as a new user")
  end
 
  it "should have a feedback page at '/feed_backs/new'" do
    get '/feed_backs/new'                                      
    response.should have_selector('title', :content => "Feedback")
  end                                                     

  it "should have the right links on the layout" do
    visit root_path
    response.should have_selector('title', :content => "Welcome to Causality Project")
    click_link "Home"
    response.should have_selector('title', :content => "Causality Project: Issues")
    click_link "Relationships"
    response.should have_selector('title', :content => "Causality Project: Relationships")
    click_link "Home"
    response.should have_selector('title', :content => "Causality Project: Relationships")
    click_link "Register"
    response.should have_selector('div[class="pageheading"]', :content => "Register as a new user")
    response.should have_selector('title', :content => "Edit user")
  end
end 
