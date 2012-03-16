class Fixvotes < ActiveRecord::Migration
  def self.up
    
  Vote.reset_column_information
  # get all relationships
  @relationships = Relationship.find(:all)
  
  @relationships.each do |rel|
    @reluserid = rel.user_id
    # votes that users cast on their own relationships
    @selfvotes = rel.votes.where(:user_id => @reluserid)
    @selfvotes.each do |vote|
        # delete such votes
        vote.destroy
      end
    end    
    
  @relationships.each do |rel|
    # if this is not an anonymous relationship
    if rel.user
      # create a vote of endorsement
      Vote.create(:user_id => rel.user_id, :relationship_id => rel.id, :vote_type => "E")
    end
  end
  
    
  end

  def self.down
  end
end
