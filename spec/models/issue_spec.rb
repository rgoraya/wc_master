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
# == Schema Information
#
# Table name: issues
#
#  id                  :integer         not null, primary key
#  title               :string(255)
#  description         :string(255)
#  wiki_url            :string(255)
#  short_url           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  permalink           :string(255)
#  user_id             :integer
#  relationships_count :integer
#

