require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Issue do
  before(:each) do 
    @issue = Issue.find_by_title("Electricity")
  end

  it "should retrieve suggestions" do
    @issue.suggestions.should_not be_empty
  end
end
