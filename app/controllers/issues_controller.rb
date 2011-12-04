class IssuesController < ApplicationController
  # GET /issues
  # GET /issues.xml
  def index
    @issues = Issue.search(params[:search]).order("created_at DESC").paginate(:per_page => 10, :page => params[:page])

    respond_to do |format|
      format.js {render :layout=>false}
      format.html # index.html.erb
      format.xml  { render :xml => @issues }
			format.json { render :json => @issues }
    end
  end
  
  # GET /issues/1
  # GET /issues/1.xml
  def show
    @issue = Issue.find(params[:id])

    @issue_cause_suggestion = @issue.suggestions.where(:causality => 'C',:status => 'N')

    @issue_effect_suggestion = @issue.suggestions.where(:causality => 'E',:status => 'N')

    @issue_inhibitor_suggestion = @issue.suggestions.where(:causality => 'I',:status => 'N')

    @issue_inhibited_suggestion = @issue.suggestions.where(:causality => 'R',:status => 'N')

    @issue_parent_suggestion = @issue.suggestions.where(:causality => 'P',:status => 'N')
    
    @issue_subset_suggestion = @issue.suggestions.where(:causality => 'S',:status => 'N')    

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue }
    end
  end

  # GET /issues/new
  # GET /issues/new.xml
  def new
    @issue = Issue.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @issue }
    end
  end

  # GET /issues/1/edit
  def edit
    @issue = Issue.find(params[:id])
  end

  # POST /issues
  # POST /issues.xml
  def create
    
    @issue = Issue.new(params[:issue])
 
    # A D D    N E W    C A U S E / E F F E C T
    if params[:action_carrier]

      # Read in the :type passed with form to recognize whether this is a Cause or Effect
      @causality = params[:action_carrier].to_s
      @causality_id = params[:id_carrier]     

      # * * * * Check whether the Cause/effect already exists as an issue * * * *
      if Issue.exists?(:wiki_url => [@issue.wiki_url])
        
        # Retrieve the ID of existing issue
        @wikiurl = @issue.wiki_url
        @issueid = Issue.where(:wiki_url => @wikiurl).select('id').first.id
        
        # Define a new Relationship
        @relationship = Relationship.new
          
          # Populate User_Id if relationship was created by a logged in User
          if @issue.user_id.to_s != ""
            @relationship.user_id = @issue.user_id  
          end            
        
        # It is a Cause
        if @causality == "C"  
          @relationship.cause_id = @issueid
          @relationship.issue_id = @causality_id
          @notice = 'New cause linked Successfully'
        end

        # It is an Inhibitor
        if @causality == "I"  
          @relationship.cause_id = @issueid
          @relationship.issue_id = @causality_id
          @relationship.relationship_type = 'I'
          @notice = 'New reducing issue linked Successfully'
        end        

        # It is a Superset
        if @causality == "P"  
          @relationship.cause_id = @issueid
          @relationship.issue_id = @causality_id
          @relationship.relationship_type = 'H'
          @notice = 'New superset linked Successfully'
        end
        
        # It is an Effect
        if @causality == "E"
          @relationship.cause_id = @causality_id
          @relationship.issue_id = @issueid      
          @notice = 'New effect linked Successfully'
        end

        # It is an Inhibited
        if @causality == "R"
          @relationship.cause_id = @causality_id
          @relationship.issue_id = @issueid      
          @relationship.relationship_type = 'I'
          @notice = 'New reduced issue linked Successfully'
        end
        
        # It is a Subset
        if @causality == "S"
          @relationship.cause_id = @causality_id
          @relationship.issue_id = @issueid
          @relationship.relationship_type = 'H'          
          @notice = 'New subset linked Successfully'
        end        
        
        save_relationship
      
      # * * * * The issue pointing to this wiki_url does not exist so create new issue before relation * * * *
      else
        if @issue.save

          suggested_causes, suggested_effects, suggested_inhibitors, suggested_reduced, suggested_parents, suggested_subsets = Suggestion.new.get_suggestions(@issue.wiki_url, @issue.id)

          Suggestion.create(suggested_causes)
          Suggestion.create(suggested_effects)
          Suggestion.create(suggested_inhibitors)
          Suggestion.create(suggested_reduced)
          Suggestion.create(suggested_parents)
          Suggestion.create(suggested_subsets)


          Reputation::Utils.reputation(:action=>:create, \
                                       :type=>:issue, \
                                       :me=>@issue.user_id, \
                                       :undo=>false, \
                                       :calculate=>true)

          # Define a new Relationship
          @relationship = Relationship.new

          # Populate User_Id if relationship was created by a logged in User
          if @issue.user_id.to_s != ""
            @relationship.user_id = @issue.user_id  
          end

          # It is a Cause
          if @causality == "C"  
            @relationship.cause_id = @issue.id
            @relationship.issue_id = @causality_id          
            @notice = 'New Issue was created and linked as a cause'
          end

          # It is an Inhibitor
          if @causality == "I"  
            @relationship.cause_id = @issue.id
            @relationship.issue_id = @causality_id
            @relationship.relationship_type = 'I'            
            @notice = 'New Issue was created and linked as reducer'
          end

          # It is a Superset
          if @causality == "P"  
            @relationship.cause_id = @issue.id
            @relationship.issue_id = @causality_id 
            @relationship.relationship_type = 'H'
            @notice = 'New Issue was created and linked as a superset'
          end         

          # It is an Effect
          if @causality == "E"  
            @relationship.cause_id = @causality_id
            @relationship.issue_id = @issue.id
            @notice = 'New Issue was created and linked as an effect'
          end          

          # It is an Inhibited
          if @causality == "R"  
            @relationship.cause_id = @causality_id
            @relationship.issue_id = @issue.id
            @relationship.relationship_type = 'I'
            @notice = 'New Issue was created and linked as reduced'
          end              

          # It is a Subset
          if @causality == "S"  
            @relationship.cause_id = @causality_id
            @relationship.issue_id = @issue.id
            @relationship.relationship_type = 'H'
            @notice = 'New Issue was created and linked as a subset'
          end  

          save_relationship

          # some problem occurred and the Issue could not be saved
        else
          @notice = @issue.errors.full_messages
          redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created')

        end
        
        # Define new Suggestions for the newly created issue
        Suggestion.new(params[:issue_id=>@issue.id, :wiki_url=>@issue.wiki_url])       
        
      end
         
    else
      
     respond_to do |format|     
        if @issue.save
        # Define new Suggestions
        #@suggestion = Suggestion.new(params[:issue_id=>@issue.id, :wiki_url=>@issue.wiki_url]) 
        #@suggestion.create

					suggested_causes, suggested_effects, suggested_inhibitors, suggested_reduced, suggested_parents, suggested_subsets = Suggestion.new.get_suggestions(@issue.wiki_url, @issue.id)

    			Suggestion.create(suggested_causes)
    			Suggestion.create(suggested_effects)
   				Suggestion.create(suggested_inhibitors)
    			Suggestion.create(suggested_reduced)
    			Suggestion.create(suggested_parents)
    			Suggestion.create(suggested_subsets)

          
          format.html { redirect_to(@issue, :notice => 'Issue was successfully created.') }
          format.xml  { render :xml => @issue, :status => :created, :location => @issue }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
        end
      end      
    end
  end

  def save_relationship
    if @relationship.save
      remove_duplicate_suggestions 
      Reputation::Utils.reputation(:action=>:create, \
                                   :type=>:relationship, \
                                   :id=>@relationship.id, \
                                   :me=>@relationship.user_id, \
                                   :undo=>false, \
                                   :calculate=>true)

      redirect_to(:back, :notice => @notice)
    else
      error_saving_causal_link
    end   
  end

  def remove_duplicate_suggestions
    if Suggestion.exists?(:causality => @causality, :wiki_url => [@issue.wiki_url], :issue_id=>@causality_id)
      @suggestion_id = Suggestion.where(:causality => @causality, :wiki_url => [@issue.wiki_url], :issue_id=>@causality_id).select('id').first.id
      @suggestion = Suggestion.find(@suggestion_id)
      @suggestion.update_attributes('status' => 'A')
      @suggestion.save
    end 
  end

  def error_saving_causal_link
    @notice = @relationship.errors.full_messages
    redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created') 
  end

  #protected
  def preview( action)
    @preview = @issue.valid?
   
    render :action => action
  end

  # PUT /issues/1
  # PUT /issues/1.xml
  def update

    @issue = Issue.find(params[:id])

    if params[:previewbutton]
      
      @issue.attributes = params[:issue]
      render :action => "edit"
      return
    
    else
    
      respond_to do |format|
        if @issue.update_attributes(params[:issue])
          format.js {render :layout=>false}
          format.html { redirect_to(@issue, :notice => 'Issue was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
        end
      end
    end
  
  end

  # DELETE /issues/1
  # DELETE /issues/1.xml
  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy

		Reputation::Utils.reputation(:action=>:destroy, \
																		:type=>:issue, \
																		:id=>@issue.id, \
																		:me=>current_user.id, \
																		:you=>@issue.user_id, \
																		:undo=>false, \
																		:calculate=>false)
    respond_to do |format|
      format.html { redirect_to(:back, :notice => 'Issue was successfully deleted') }
      format.xml  { head :ok }
    end
  end
  
  
  def causality
    
    @issue = Issue.new(params[:issue])
 
    if @issue.save
      format.html { redirect_to(@index, :notice => 'Issue successfully added.') }
    end
    
  end

#issues/:id/versions
	def versions
		@issue = Issue.find(params[:id])
		@versions = []
		Version.find(:all, :conditions => ["item_type=?", 'Relationship']).each do |version|
			relationship = version.get_object #should return a Relationshiop object here
			if relationship.issue_id == @issue.id || relationship.cause_id == @issue.id
				@versions << version
			end
		end 
		@versions.sort!{|a,b| b.created_at <=> a.created_at}
		@versions = @versions.paginate(:page => params[:page], :per_page => 10)

		respond_to do |format|
			format.html
			format.xml 
		end
	end

#issues/:id/snapshot/:at
	def snapshot
		ids = []
		versions = []
		versions_buffer = []
		Version.find(:all, :conditions => ["item_type = 'Relationship'"], :order => 'created_at ASC').each do |version|
			relationship = version.get_object
			if (relationship.issue_id == params[:id].to_i || relationship.cause_id == params[:id].to_i) && version.created_at <= DateTime.parse(params[:at])
				versions_buffer << version
			end
		end
		versions_buffer.sort!{|a,b| b.created_at <=> a.created_at}
		versions_buffer.each do |version|
			if !ids.include?(version.item_id)
				versions << version
				ids << version.item_id
			end
		end

		relationships = []
		@causes = []
		@effects = []
		versions.each do |version|
			if !version.event.eql?('destroy')
				relationships << version.get_object
			end
		end
		relationships.each do |relationship|
			if relationship.issue_id == params[:id].to_i
				@causes << Issue.find(relationship.cause_id)
			elsif relationship.cause_id == params[:id].to_i
				@effects << Issue.find(relationship.issue_id)
			end
		end
		@issue = Issue.find(params[:id])
		@description = "Snapshot of #{@issue.title} up to #{DateTime.parse(params[:at]).strftime('%b %d %Y - %R:%S')}"
		respond_to do |format|
			format.html 
			format.xml 
		end		
	end
end
