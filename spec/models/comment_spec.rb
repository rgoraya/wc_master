require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do
  before(:each) do 
    @comment = Comment.new(:content => 'example', :relationship_id => 11)
  end
  
  it 'should be valid when new' do 
    @comment.should be_valid
  end

  it 'should not be valid if missing content' do
    @comment.content= ''
    @comment.should_not be_valid
  end

  it 'should not be valid if missing relationship_id' do
    @comment.relationship_id = ''
    @comment.should_not be_valid
  end

  it 'should contain a well formed relationship_id' do
    @comment.relationship_id = 'hffp://ashla.com'
    @comment.should_not be_valid
    @comment.relationship_id = 'la.com'
    @comment.should_not be_valid 
    @comment.relationship_id = 102381923809123
    @comment.should be_valid
    @comment.relationship_id = 1
    @comment.should be_valid          
  end                                       
end  
# == Schema Information
#
# Table name: comments
#
#  id              :integer         not null, primary key
#  content         :string(255)
#  relationship_id :integer
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#

