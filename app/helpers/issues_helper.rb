module IssuesHelper

  def get_vote
    @vote = @relationship.votes.where(:user_id => current_user.id).first
  end

  def set_voter_message
    case @vote.vote_type
      when 'E'
        @message = "You endorse this relation"
      when 'C'
        @message = "You contest this relation"
      when 'A'
        @message = "You flagged this relation as offensive"      
    end
  end

  def set_initial_message
    @message = "You haven't voted on this relation"
  end

  def set_owner_message
    @message = "You own and endorse this relation" 
  end

  def get_vote_percentages
    @totalvotes   = @relationship.endorsements.length + @relationship.contestations.length + @relationship.accusations.length  
    if @totalvotes > 0
      @endorsevotes = @relationship.endorsements.length.to_f
      @contestvotes = @relationship.contestations.length.to_f
      @accusevotes  = @relationship.accusations.length.to_f
      @endorseperc  = (@endorsevotes/@totalvotes)*100
      @contestperc  = (@contestvotes/@totalvotes)*100
      @accuseperc   = (@accusevotes/@totalvotes)*100    
    end
    
  end

end
