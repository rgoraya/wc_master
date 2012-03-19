require "rspec"
require 'spec_helper'


describe IssuesController do
  before do
    @issue = Issue.find_by_title('Electricity')
  end
  
  it "redirects to the issue on successful save" do
    post :create, :issue => @issue.attributes
    @issue.id = nil
    assigns[:issue].should == (@issue)
    @issue.id = 1
    response.should redirect_to(@issue)
  end                                

  it "redirects to back on non-successful save" do
    post :create, :issue => @issue.attributes
    @issue.id = nil
    assigns[:issue].should == (@issue)
  end                                
end                          

describe "When I show an issue" do
  before(:each) do 
    @issue = Issue.find_by_title('Electricity')
  end

  it "should show its causes" do
    issue_cause_suggestion = @issue.suggestions.where(:causality => 'C',:status => 'N')
  end       

  it "should show its effects" do
    issue_effect_suggestion = @issue.suggestions.where(:causality => 'E',:status => 'N')
  end        

  it "should show what reduces it" do
    issue_inhibitor_suggestion = @issue.suggestions.where(:causality => 'I',:status => 'N')
  end         

  it "should show what it reduces" do
    issue_inhibited_suggestion = @issue.suggestions.where(:causality => 'R',:status => 'N')
  end       

  it "should show its supersets" do
    issue_parent_suggestion = @issue.suggestions.where(:causality => 'P',:status => 'N')
  end       

  it "should show its subsets" do
    issue_subset_suggestion = @issue.suggestions.where(:causality => 'S',:status => 'N')    
  end       
end                          

