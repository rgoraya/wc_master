class VotesController < ApplicationController
  # GET /votes
  # GET /votes.xml
  def index
    @votes = Vote.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @votes }
    end
  end

  # GET /votes/1
  # GET /votes/1.xml
  def show
    @vote = Vote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vote }
    end
  end

  # GET /votes/new
  # GET /votes/new.xml
  def new
    @vote = Vote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vote }
    end
  end

  # GET /votes/1/edit
  def edit
    @vote = Vote.find(params[:id])
  end

  # POST /votes
  # POST /votes.xml
  def create
    @vote = Vote.new(params[:vote])
    
    @relationship = Relationship.find(@vote.relationship_id)
    
    # store the vote_type to create the notice
    @vote_type = @vote.vote_type
    
    # Check if the same user has already voted for this particular relationship
    if Vote.exists?(:user_id => @vote.user_id, :relationship_id => @vote.relationship_id)
      
      # This means that we are here because the user has earlier endorsed/contested 
      # the same relationship but now wants to do the reverse 
      @vote_to_update = Vote.where(:user_id => @vote.user_id, :relationship_id => @vote.relationship_id).first
      
      # Therefore we update that existing record with the new vote_type
      # @vote_to_update.update_attribute(:vote_type, @vote.vote_type)
      respond_to do |format|
        if @vote_to_update.update_attributes(params[:vote])
          #get_appropriate_notice(@vote_type)
          format.html { redirect_to(@vote_to_update, :notice => 'Vote was successfully updated.') }
          format.xml  { head :ok }
          format.js
       else
          #@notice = @vote.errors.full_messages.join(", ")
          format.html { render :action => "edit" }
          format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
        format.js
        end
      end
    
    # This is a new vote (user hasn't voted on this relationship yet). Just create it.  
    else
      respond_to do |format|
        if @vote.save
          #get_appropriate_notice(@vote_type)
          format.html { redirect_to(@vote, :notice => 'Vote was successfully created.') }
          format.xml  { render :xml => @vote, :status => :created, :location => @vote }
          format.js
        else
          #@notice = @vote.errors.full_messages.join(", ")
          format.html { render :action => "new" }
          format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
          format.js
        end
      end        
    end
    
  def get_appropriate_notice(vote_type)
    case vote_type       
      when "E"
        @notice = "You endorse this relationship now."
      when "C"
        @notice = "You contest this relationship now."     
    end  
  end


  end

  # PUT /votes/1
  # PUT /votes/1.xml
  def update
    @vote = Vote.find(params[:id])

    respond_to do |format|
      if @vote.update_attributes(params[:vote])
        format.html { redirect_to(@vote, :notice => 'Vote was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /votes/1
  # DELETE /votes/1.xml
  def destroy
    @vote = Vote.find(params[:id])
    @relationship = Relationship.find(@vote.relationship_id)
    @vote.destroy

    respond_to do |format|
      format.html { redirect_to(votes_url) }
      format.xml  { head :ok }
      format.js
    end
  end
end
