require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Issue do
  before(:each) do 
    @issue = Issue.new(:title => 'example', :description => 'example description', :wiki_url=> 'http://en.wikipedia.org/wiki/Electricity_issues', 
                       :short_url => 'http://upload.wikimedia.org/wikipedia/commons/thumb...')
  end
  
  it 'should be valid when new' do 
    @issue.should be_valid
  end

  it 'should not be valid if missing title' do
    @issue.title = ''
    @issue.should_not be_valid
  end

  it 'should not be valid if missing wiki_url' do
    @issue.wiki_url = ''
    @issue.should_not be_valid
  end

  it 'should contain a well formed wiki_url' do
    @issue.wiki_url = 'hffp://ashla.com'
    @issue.should_not be_valid
    @issue.wiki_url = 'hfasal/ashla.com'
    @issue.should_not be_valid 
    @issue.wiki_url = 'http://en.wikipedia.org'
    @issue.should be_valid          
    
  end               

  it 'should not be valid if missing short_url' do
    @issue.short_url = ''
    @issue.should_not be_valid
  end                                         

  it 'should not be valid if missing description' do
    @issue.description = ''
    @issue.should_not be_valid
  end                                         
end
