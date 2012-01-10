require "rspec"
require 'spec_helper'


describe "When I create an issue" do
  before do
    @attributes = {:title => 'example', :wiki_url => 'examplewiki',
                      :short_url => 'exampleshort', :description => 'exampledescription'}
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
               
  it "retrieves suggestions and shows them" do
  end                                

  it "may have an user" do
  end 

  it "may have not an user" do
  end
end                          

describe "When I show an issue" do
  before(:each) do 
    issue = Issue.find(:title => 'Sex')
  end

  it "should show its causes" do
    issue_cause_suggestion = issue.suggestions.where(:causality => 'C',:status => 'N')
  end       

  it "should show its effects" do
    issue_effect_suggestion = issue.suggestions.where(:causality => 'E',:status => 'N')
  end        

  it "should show what reduces it" do
    issue_inhibitor_suggestion = issue.suggestions.where(:causality => 'I',:status => 'N')
  end         

  it "should show what it reduces" do
    issue_inhibited_suggestion = issue.suggestions.where(:causality => 'R',:status => 'N')
  end       

  it "should show its supersets" do
    issue_parent_suggestion = issue.suggestions.where(:causality => 'P',:status => 'N')
  end       

  it "should show its subsets" do
    issue_subset_suggestion = issue.suggestions.where(:causality => 'S',:status => 'N')    
  end       
end                          

