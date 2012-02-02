require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "When I create an issue" do

  before(:each) do 
    @issue = Issue.new(:id => 22, :title => "Solar cell", :description => "A solar cell (also called photovoltaic cell or phot...", 
                       :wiki_url => "http://en.wikipedia.org/wiki/Solar_cell", :short_url => "//upload.wikimedia.org/wikipedia/commons/thumb/9/90...", 
                       :created_at => "2012-01-20 21:19:39", :updated_at => "2012-01-20 21:19:39", :permalink => "solar-cell", :user_id => nil)
  end

  it "should retrieve suggestions" do

    true.should == false
  end
end
