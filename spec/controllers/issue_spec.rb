require "rspec"
require 'spec_helper'


describe IssuesController do
  render_views

  describe "POST 'create'" do
    describe "success" do
      before(:each) do
        @attr = { :title       => "Example", 
          :wiki_url    => "http://en.wikipedia.org/wiki/Long_Island",
          :short_url   => "http://en.wikipedia...", 
          :description => "example description"}
      end  

      it "should redirect to the issue page" do
        post :create, :issue => @attr
        response.should redirect_to(issue_path(assigns(:issue)))
      end

      it "should create an issue" do
        lambda do 
          post :create, :issue => @attr
        end.should change(Issue, :count).by(1)
      end  
    end

    describe "failure" do
      before(:each) do
        @issue = FactoryGirl.create(:issue)
        @attr = @issue.attributes.merge!( :title => "", :wiki_url => "" ) 
      end                         

      it "should not create an issue" do
        lambda do 
          post :create, :issue => @attr
        end.should_not change(Issue, :count)
      end  

      it "should render the new page" do
        post :create, :issue => @attr
        response.should render_template 'issues/new'
      end
    end

  end

  describe "EDIT" do
    it "shouldn't open an edit page" do
      get :edit, :id => 1  
      response.should redirect_to(session[:return_to])
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @issue = FactoryGirl.create(:issue)
    end
    it "should destroy the issue" do
      issues_count = Issue.count
      @issue.destroy
      Issue.count.should == (issues_count-1)
    end
  end


  describe "When I show an issue" do
    before(:each) do 
      @issue = FactoryGirl.create(:issue)
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

end                          


