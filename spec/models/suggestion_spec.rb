require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Suggestion do

  before(:each) do 
    @suggestion = Suggestion.new(:title => 'example', :wiki_url => 'http://example.com', :causality => 'H', :status => 'A')
  end
  
  it 'should be valid when new' do 
    @suggestion.should be_valid
  end

  it 'should not be valid if missing title' do
    @suggestion.title = ''
    @suggestion.should_not be_valid
  end

  it 'should not be valid if missing wiki_url' do
    @suggestion.wiki_url = ''
    @suggestion.should_not be_valid
  end

  it 'should contain a well formed wiki_url' do
    @suggestion.wiki_url = 'hffp://ashla.com'
    @suggestion.should_not be_valid
    @suggestion.wiki_url = 'hfasal/ashla.com'
    @suggestion.should_not be_valid 
    @suggestion.wiki_url = 'http://en.wikipedia.org/wiki/Solar_cell'
    @suggestion.should be_valid          
    
  end               

  it 'should not be valid if missing causality' do
    @suggestion.causality = ''
    @suggestion.should_not be_valid
  end                    

  it 'should not be valid if wrong causality' do
    @suggestion.causality = 'asdjlkaX'
    @suggestion.should_not be_valid
  end                               

end 
