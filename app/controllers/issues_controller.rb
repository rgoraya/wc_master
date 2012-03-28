class IssuesController < ApplicationController
require 'backports' 

  #-------------------------------------------------------------------
  # RESTFUL: ISSUE INDEX 
  #-------------------------------------------------------------------    
  def index
      
      # setting the default sort criteria
      if (params[:sort_by])
        @sort_by = params[:sort_by]  
      else 
        @sort_by = "Alphabetical order" 
      end

      # set the @issues for the sort criteria
      case @sort_by
        when "Alphabetical order"
          @issues = Issue.search(params[:search]).order("title").paginate(:per_page => 20, :page => params[:page]) 
        when "Most recent"  
          @issues = Issue.search(params[:search]).order("created_at DESC").paginate(:per_page => 20, :page => params[:page])
        when "Relationship count"
          @issues = Issue.search(params[:search]).order("relationships_count DESC").paginate(:per_page => 20, :page => params[:page]) 
      end
     
    respond_to do |format|
      format.js 
      format.html # index.html.erb
      format.xml  { render :xml => @issues }
      format.json { render :json => @issues }
    end
  end

  #-------------------------------------------------------------------
  # RESTFUL: ISSUE SOW 
  #-------------------------------------------------------------------  
  def show
    # get the current issue
    @issue = Issue.find(params[:id]) 

    @causal_sentence = ""  # initialize the causal sentence

    # respond according to the kind of request
    respond_to do |format|
      
      format.html do   # html request
        if @issue.suggestions == []   # if this issue does not have any suggestions, try populating them
          load_suggestions
        end
      
        if params[:rel_type]    # check for the requested relationship type
          @rel_type = params[:rel_type]
          @causal_sentence = params[:rel_type]
          get_selected_relations # Call to retrieve the corresponding relationships
        end      

        if params[:rel_id]      # if this request also wants info for a particular relationship
          get_selected_relationship
        end
      
      end
      
      format.js do      # AJAX request (JS)
        
        if params[:rel_type]   # check for rel_type only if no particular relationship was requested
          @rel_type = params[:rel_type]
          get_selected_relations  # Call to retrieve the corresponding relationships
        end

        if params[:rel_id]      # if this request also wants info for a particular relationship
          get_selected_relationship
        end
                
      end
      format.xml  { render :xml => @issue }   # XML request
    end

  end

  #-------------------------------------------------------------------
  # SELECTED TYPE OF RELATIONSHIPS (THUMBNAILS ON THE SHOW PAGE)
  #------------------------------------------------------------------- 
  def get_selected_relations
    
    # getting the page number if this call has the relationship_id parameter
    # this means, the thumbnails would contain the requested relationship 
    # even if it is not on the first page
    if params[:rel_id] && params[:rel_id] != "" && !params[:page]
      @rel_to_check = Relationship.find(params[:rel_id])
      @page = get_page_number_of_this_rel(@rel_type, @rel_to_check)
    else
      @page = params[:page]
    end
    
    # relationship type to be sent back    
    case @rel_type       

      when "is caused by"
        @issue_relations = @issue.causes.paginate(:per_page => 6, :page => @page)
        set_selected_relations_common_data('C',nil,"add_cause_btn","causes")
      when "causes"
        @issue_relations = @issue.effects.paginate(:per_page => 6, :page => @page)
        set_selected_relations_common_data('E',nil,"add_effect_btn","effects")
             
      when "is reduced by"
        @issue_relations = @issue.inhibitors.paginate(:per_page => 6, :page => @page)
        set_selected_relations_common_data('I','I',"add_inhibitor_btn","inhibitors")
            
      when "reduces"
        @issue_relations = @issue.inhibiteds.paginate(:per_page => 6, :page => @page)
        set_selected_relations_common_data('R','I',"add_inhibited_btn","inhibiteds")
             
      when "is a subset of"
        @issue_relations = @issue.supersets.paginate(:per_page => 6, :page => @page)
        set_selected_relations_common_data('P','H',"add_superset_btn","supersets")
            
      when "is a superset of"
        @issue_relations = @issue.subsets.paginate(:per_page => 6, :page => @page)
        set_selected_relations_common_data('S','H',"add_subset_btn","subsets")
         
   end
   
  end

  #-------------------------------------------------------------------
  # METHOD TO FIND OUT THE PAGE NUMBER FOR THE PAGINATION 
  #-------------------------------------------------------------------  
  def get_page_number_of_this_rel(rel_type, rel_to_check)
    
    # number of items shown at a time
    number_per_page = 6
    
    # find out how many items occur before this relationship
    case rel_type       
      when "is caused by"
      records_before_this_one = @issue.causes.count(:conditions => ['relationships.updated_at > ?', rel_to_check.updated_at], :order => 'relationships.updated_at DESC')
      when "causes"
      records_before_this_one = @issue.effects.count(:conditions => ['relationships.updated_at > ?', rel_to_check.updated_at], :order => 'relationships.updated_at DESC')
      when "is reduced by"
      records_before_this_one = @issue.inhibitors.count(:conditions => ['relationships.updated_at > ?', rel_to_check.updated_at], :order => 'relationships.updated_at DESC')
      when "reduces"
      records_before_this_one = @issue.inhibiteds.count(:conditions => ['relationships.updated_at > ?', rel_to_check.updated_at], :order => 'relationships.updated_at DESC')
      when "is a subset of"
      records_before_this_one = @issue.supersets.count(:conditions => ['relationships.updated_at > ?', rel_to_check.updated_at], :order => 'relationships.updated_at DESC')
      when "is a superset of"
      records_before_this_one = @issue.subsets.count(:conditions => ['relationships.updated_at > ?', rel_to_check.updated_at], :order => 'relationships.updated_at DESC')
    end

    # the page number formula! 
    page = (records_before_this_one / number_per_page) + 1
  
  end

  #-------------------------------------------------------------------
  # METHOD TO DISPLAY SUGGESTIONS BASED ON RELATIONSHIP TYPE 
  #-------------------------------------------------------------------  
  def retrieve_suggestions(type_of_suggestions, num_of_suggestions_to_pull)
    case type_of_suggestions
    when "causes"
      @suggestions = @issue.suggestions.where(:causality => 'C',:status => 'N').limit(num_of_suggestions_to_pull)
    when "effects"
      @suggestions = @issue.suggestions.where(:causality => 'E',:status => 'N').limit(num_of_suggestions_to_pull)
    when "inhibitors"
      @suggestions = @issue.suggestions.where(:causality => 'I',:status => 'N').limit(num_of_suggestions_to_pull)
    when "inhibiteds"
      @suggestions = @issue.suggestions.where(:causality => 'R',:status => 'N').limit(num_of_suggestions_to_pull)
    when "supersets"
      @suggestions = @issue.suggestions.where(:causality => 'P',:status => 'N').limit(num_of_suggestions_to_pull)
    when "subsets"
      @suggestions = @issue.suggestions.where(:causality => 'S',:status => 'N').limit(num_of_suggestions_to_pull)
    end
  end

  #-------------------------------------------------------------------
  # METHOD TO SET COMMON DATA 
  #-------------------------------------------------------------------
  def set_selected_relations_common_data(causality, relationship_type, add_btn_id, type_of_suggestions)

    @issue_relations.each do |relation|
      if(causality.eql? 'E' or causality.eql? 'R' or causality.eql? 'S')
        @reltn_id = Relationship.where(:issue_id=>relation.id, :cause_id=>@issue.id, :relationship_type=>relationship_type).select('id').first.id
        relation.wiki_url = @reltn_id
      else 
        @reltn_id = @issue.relationships.where(:cause_id=>relation.id, :relationship_type=>relationship_type).select('id').first.id
        relation.wiki_url = @reltn_id 
      end
    end
    @add_btn_id      = add_btn_id

    if @issue_relations.length < 6
      num_of_suggestions_to_pull = (6 - @issue_relations.length)         
      retrieve_suggestions(type_of_suggestions, num_of_suggestions_to_pull)
		else
			@suggestions = []
    end  
  end 

  #-------------------------------------------------------------------
  # RETRIEVE THE REQUESTED RELATIONSHIP (PARTICULAR RELATIONSHIP ID)
  #------------------------------------------------------------------- 
  def get_selected_relationship    
    @rel_id = params[:rel_id].to_s
    @relationship = Relationship.find(params[:rel_id])  # relationship 
    @rel_issue    = Issue.find(@relationship.issue_id)  # the issue on left side of the relation
    @rel_cause    = Issue.find(@relationship.cause_id)  # the issue on right side of the relation
    
    if @issue.id == @rel_cause.id                       
      @rel_issue, @rel_cause = @rel_cause, @rel_issue   # swap them depending upon the requested issue page
      @causal_sentence = get_reverted_causal_sentence
    else
      @causal_sentence = get_causal_sentence
    end
    
  end
    
  def get_reverted_causal_sentence
    case @relationship.relationship_type
      when nil
        sentence = "causes"
      when 'I'
        sentence = "reduces"
      when 'H'
        sentence = "is a superset of" 
     end
  end  

  def get_causal_sentence
    case @relationship.relationship_type
      when nil
        sentence = "is caused by"
      when 'I'
        sentence = "is reduced by"
      when 'H'
        sentence = "is a subset of" 
    end
  end     

  #-------------------------------------------------------------------
  # LOAD SUGGESTIONS IF REQUESTED
  #-------------------------------------------------------------------
  def load_suggestions
    Suggestion.new(params[:issue_id=>@issue.id, :wiki_url=>@issue.wiki_url])  # Suggestions for new issue  
    initialize_suggestion_object
  end

  def initialize_suggestion_object
    suggested_causes, suggested_effects, suggested_inhibitors, suggested_reduced, suggested_parents, suggested_subsets = Suggestion.new.get_suggestions(@issue.wiki_url, @issue.id)
    Suggestion.create(suggested_causes)
    Suggestion.create(suggested_effects)
    Suggestion.create(suggested_inhibitors)
    Suggestion.create(suggested_reduced)
    Suggestion.create(suggested_parents)
    Suggestion.create(suggested_subsets) 
  end

  #-------------------------------------------------------------------
  # SITE WIDE AUTO-COMPLETE SEARCH
  #-------------------------------------------------------------------
  def auto_complete_search
    @search_results = Issue.search(params[:query].strip).first(5)
    @search_count   = @search_results.length
    
    respond_to do |format|
      format.js 
      format.html do
        
        if params[:selected_data] and params[:selected_data] != '' #handle selected_data (a selected url) if available
          redirect_to params[:selected_data]
        else

          redirect_to :controller => 'issues', :action => 'index', :search => params[:query]
        end
      end
    end 
  end

  #-------------------------------------------------------------------
  # RESTFUL: ISSUE NEW
  #-------------------------------------------------------------------
  def new
    @issue = Issue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @issue }
    end
  end

  #-------------------------------------------------------------------
  # RESTFUL: ISSUE EDIT
  #-------------------------------------------------------------------
  def edit
    @issue = Issue.find(params[:id])
  end

  #-------------------------------------------------------------------
  # RESTFUL: ISSUE CREATE
  #-------------------------------------------------------------------
  def create
    @issue = Issue.new(params[:issue])

    if params[:action_carrier] # WE ARE HERE TO ADD NEW CAUSE/EFFECT
      
      # Read in the :type passed with form to recognize Relationship Type
      @causality = params[:action_carrier].to_s
      @causality_id = params[:id_carrier]     
      
      # Check whether or not this Node exist as an issue already?
      # IMPORTANT: Keep the search case-insensitive
      @existing_issue = Issue.where('lower(wiki_url) = ?', @issue.wiki_url.to_s.downcase).first
      if !@existing_issue.nil?
        add_already_existent_issue
      else
        add_new_issue
      end
      
    else                      # WE ARE HERE TO CREATE THE FIRST NODE ISSUE
      
      # Check whether this Issue already exists
      @existing_issue = Issue.where('lower(wiki_url) = ?', @issue.wiki_url.to_s.downcase).first
      if !@existing_issue.nil?
        
        redirect_to(@existing_issue)    # if so then simply redirect to the Show page of that Issue
      
      else                              # If not, go ahead and create a new one
        respond_to do |format|     
          if @issue.save
  					Reputation::Utils.reputation(:action=>:create, \
                                     :type=>:issue, \
                                     :me=>@issue.user_id, \
                                     :undo=>false, \
                                     :calculate=>true)
  
            format.html { redirect_to(@issue, :notice => 'Issue was successfully created.') }
            format.xml  { render :xml => @issue, :status => :created, :location => @issue }
            format.js
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
            format.js
          end
        end
      end      
    end
  end

  def add_already_existent_issue
    retrieve_id_of_issue
    @relationship = Relationship.new
    set_relationship_user_id_if_applicable 
    set_type_of_relationship(true)
		if !check_if_same_relationship_existed       
    	save_relationship
		end
		 
  end

	def check_if_same_relationship_existed
		vs = []

  		Version.order("created_at DESC").find(:all, :conditions=>["item_type=?","Relationship"]).each do |version|
  			rel = version.get_object
  			@rel_id = rel.id.to_s
  			if rel.issue_id == @relationship.issue_id && rel.cause_id == @relationship.cause_id && rel.relationship_type == @relationship.relationship_type
  				vs << version
  				@notice="Relationship already exists!"
  				break
  			end
  		end

  		if current_user && !vs.empty? && vs.last.event.eql?("destroy")
  			vs.last.restore
  			@notice = "An identical relationship used to exist. It is now restored!"
  		elsif !current_user && !vs.empty? && vs.last.event.eql?("destroy")
  			@notice = "An identical relationship used to exist. Please login to restore this relationship."      
  		end

		  return !vs.empty?
	end


  def retrieve_id_of_issue
    @wikiurl = @issue.wiki_url
    @issueid = @existing_issue.id
  end

  def set_relationship_user_id_if_applicable
    if @issue.user_id.to_s != ""
      @relationship.user_id = @issue.user_id  
    end 
  end

  def update_img_if_applicable
    # if the image selected by the user is different than the one saved then update it.
    if !@existing_issue.nil?
      if @issue.short_url != @existing_issue.short_url 
        @existing_issue.update_attribute(:short_url, @issue.short_url)
      end 
    end
  end

  def add_new_issue
    if @issue.save
      Reputation::Utils.reputation(:action=>:create, \
                                   :type=>:issue, \
                                   :me=>@issue.user_id, \
                                   :undo=>false, \
                                   :calculate=>true)

      @relationship = Relationship.new
      set_relationship_user_id_if_applicable
      set_type_of_relationship(false)
      save_relationship #I don't add check_if_same_relationship_existed here because of the assumption that issues are never to be deleted. Hence, the same relationship couldn't have existed before - Duyet
    else
      @notice = @issue.errors.full_messages.join(", ")
      #redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created - Issue did not exist')
    end  
  end

  def set_type_of_relationship(already_exists)
    args = { 
        :C => [nil, 'a cause',    'cause'],
        :I => [:I,  'a reducer',  'reducer issue'],
        :P => [:H,  'a superset', 'superset'],
        :E => [nil, 'an effect',  'effect'],
        :R => [:I,  'reduced',    'reduced issue'],
       	:S => [:H,  'a subset',   'subset'] 
      }[@causality.to_sym]

    (@notice = 'Error creating and linking issue' and return) if args.nil?

    issue_id = already_exists ? @issueid : @issue.id
    ids = [issue_id, @causality_id]
    ids = ids.rotate if %W[E R S].member? @causality
    @relationship.cause_id, @relationship.issue_id = ids
    @relationship.relationship_type = args[0].try(:to_s)   

    @notice = if already_exists
                "New #{args[2]} linked Successfully"
              elsif params[:rel_suggestion_id] != ""
                "Suggestion accepted as a #{args[1]}"     
              else
                "New Issue was created and linked as #{args[1]}"
              end
  end

  def save_relationship
    if @relationship.save
      @rel_id = @relationship.id.to_s
      self_endorse
      remove_duplicate_suggestions
      update_img_if_applicable 
      Reputation::Utils.reputation(:action=>:create, \
                                   :type=>:relationship, \
                                   :id=>@relationship.id, \
                                   :me=>@relationship.user_id, \
                                   :undo=>false, \
                                   :calculate=>true)

      #redirect_to(:back, :notice => @notice)
    else
      @notice = @relationship.errors.full_messages.join(", ")    
    end   
  end

  def self_endorse
    if @relationship.user
      Vote.create(:user_id => @relationship.user_id, :relationship_id => @relationship.id, :vote_type => "E")
    end    
  end

  def remove_duplicate_suggestions
    
    # if this is a case of user 'accepting' a suggestion 
    if params[:rel_suggestion_id] != ""
      @suggestion = Suggestion.find(params[:rel_suggestion_id])
      @suggestion.update_attributes('status' => 'A')
      @suggestion.save
    
    else
      # If not then check to remove the suggestions based on wikipedia URL and the Causality type
      if Suggestion.exists?(:causality => @causality, :wiki_url => [@issue.wiki_url], :issue_id=>@causality_id)
        @suggestion_id = Suggestion.where(:causality => @causality, :wiki_url => [@issue.wiki_url], :issue_id=>@causality_id).select('id').first.id
        @suggestion = Suggestion.find(@suggestion_id)
        @suggestion.update_attributes('status' => 'A')
        @suggestion.save
      end 
    end
  end

  def error_saving_causal_link
    @notice = @relationship.errors.full_messages.join(", ")
    #redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created') 
  end

  #protected
  def preview( action)
    @preview = @issue.valid?

    render :action => action
  end

  #-------------------------------------------------------------------
  # RESTFUL: ISSUE UPDATE
  #------------------------------------------------------------------- 
  def update

    @issue = Issue.find(params[:id])

    if params[:update_image]   # WE ARE HERE TO UPDATE THE IMAGE OF THE ISSUE
      
      @issue.attributes = params[:issue]
      if @issue.save
        @notice = "Image replaced!"
        respond_to do |format|
          format.html 
          format.js {render(:layout=>false)}
        end
      else
        @notice = "Cannot Replace!"
        respond_to do |format|
          format.html 
          format.js {render(:layout=>false)}
        end        
      end
      


    else

      respond_to do |format|
        if @issue.update_attributes(params[:issue])
          format.js   {render :layout=>false}
          format.html { redirect_to(@issue, :notice => 'Issue was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
        end
      end
    end

  end

  #-------------------------------------------------------------------
  # RESTFUL: ISSUE DESTROY
  #------------------------------------------------------------------- 
  def destroy
    @issue = Issue.find(params[:id])
    @called_from = params[:called_from]
    @issue.destroy

    # setting the default sort criteria
    if (params[:sort_by])
      @sort_by = params[:sort_by]  
    else 
      @sort_by = "Alphabetical order" 
    end

    # set the @issues for the sort criteria
    case @sort_by
      when "Alphabetical order"
        @issues = Issue.search(params[:search]).order("title").paginate(:per_page => 20, :page => params[:page]) 
      when "Most recent"  
        @issues = Issue.search(params[:search]).order("created_at DESC").paginate(:per_page => 20, :page => params[:page])
      when "Relationship count"
        @issues = Issue.search(params[:search]).order("relationships_count DESC").paginate(:per_page => 20, :page => params[:page]) 
    end
    
    Reputation::Utils.reputation(:action=>:destroy, \
                                 :type=>:issue, \
                                 :id=>@issue.id, \
                                 :me=>current_user.id, \
                                 :you=>@issue.user_id, \
                                 :undo=>false, \
                                 :calculate=>true)
   
    @notice = "Issue Deleted!"
    
    respond_to do |format|
      format.html { redirect_to(:back, :notice => 'Issue was successfully deleted') }
      format.xml  { head :ok }
      format.js     
    end
  end


  #issues/:id/versions
  def versions
    @issue = Issue.find(params[:id])
		@versions = []
		if Version.last.id - params[:more].to_i >= 0
			Version.order("created_at DESC").find(:all, :conditions=>["id <= ? AND item_type = ?", Version.last.id-params[:more].to_i, "Relationship"]).each do |version|
				relationship = version.get_object
				if relationship.issue_id == @issue.id || relationship.cause_id == @issue.id
					@versions << version
				end
				@versions.count == 10 ? break : next	
			end 
		end


    respond_to do |format|
			format.js {render :layout=>false}
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
