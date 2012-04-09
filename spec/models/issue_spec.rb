require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Issue do


  describe "accessible attributes" do
    before(:each) do
      @issue = Issue.new(title: "Electricity", 
                         description: "Electricity is the science, engineering, technology...",
                         wiki_url: "http://en.wikipedia.org/wiki/Electricity", 
                         short_url: "http://upload.wikimedia.org/wikipedia/commons/thumb...")
    end 

    it { should respond_to(:title) }
    it { should respond_to(:description) }
    it { should respond_to(:wiki_url) }
    it { should respond_to(:short_url) }
    it { should respond_to(:relationships) }
    it { should respond_to(:relationships_count) }
    it { should respond_to(:user_id) }
    it { should respond_to(:to_param) }

  end

  describe "when you show an issue" do
    before(:each) do 
      @issue = Issue.find_by_title("Electricity")
    end

    it "should retrieve suggestions" do
      @issue.suggestions.should_not be_empty
    end  
 
    it "should generate good permalinks" do
      @issue.to_param.should == "#{@issue.id}-#{@issue.permalink}"
    end        
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

