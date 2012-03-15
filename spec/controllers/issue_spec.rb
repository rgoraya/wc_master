require "rspec"
require 'spec_helper'


describe IssuesController do
  before do
    @attributes = {'id' => 107, 'title' => "Electricity", 'description' => "Electricity is the science, engineering, technology...", 
      'wiki_url' => "http://en.wikipedia.org/wiki/Electricity", 'short_url' => "http://upload.wikimedia.org/wikipedia/commons/thumb...", 'created_at' => "2012-03-08 12:17:56", 'updated_at' => "2012-03-08 12:17:56", 'permalink' => "electricity"}
    @issue = mock_model(Issue)
    Issue.should_receive(:new).with(@attributes).once.and_return(@issue)
  end

  it "redirects to the issue on successful save" do
    @issue.should_receive(:save).with().once.and_return(true)

    post :create, :issue => @attributes
    assigns[:issue].should be(@issue)
    flash[:notice].should_not be(nil)    
    response.should redirect_to(@issue)
  end                                

  it "redirects to back on non-successful save" do
    @issue.should_receive(:save).with().once.and_return(true)

    post :create, :issue => @attributes
    assigns[:issue].should be(@issue)
    flash[:notice].should_not be(nil)    
    response.should redirect_to(:back)
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

