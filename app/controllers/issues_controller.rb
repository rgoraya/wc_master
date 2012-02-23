class IssuesController < ApplicationController
  # GET /issues
  # GET /issues.xml

require 'backports'
  
  def index
    @issues = Issue.search(params[:search]).order("created_at DESC").paginate(:per_page => 20, :page => params[:page])
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

    load_suggestions

    # Default params to "causes" for initial load
    if params[:rel_type]
      @rel_type = params[:rel_type];
    else
      @rel_type = "is caused by"
    end

    # Call to retrieve the corresponding relationships based on the params
    get_selected_relations

    # Default params to "causes" for initial load
    if params[:rel_id]
      @relationship = Relationship.find(params[:rel_id])
      @rel_references = @relationship.references
      @rel_issue = Issue.find(@relationship.issue_id)
      @rel_cause = Issue.find(@relationship.cause_id)
      @issue_id = params[:issueid]
      if @issue.id == @rel_cause.id # then swap!
        @rel_issue, @rel_cause = @rel_cause, @rel_issue  
      end
      @causal_sentence = @rel_type
    end

    @references = Issue.rel_references(params[:rel_id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue }
      format.js

    end
  end

  def load_suggestions
    Suggestion.new(params[:issue_id=>@issue.id, :wiki_url=>@issue.wiki_url])  # Suggestions for new issue  
    if @issue.save      
      initialize_suggestion_object
      remove_duplicate_suggestions
    else
      @notice = @issue.errors.full_messages.join(", ")   
    end

  def get_selected_relations
    case @rel_type       

    when "is caused by"
      @issue_relations = @issue.causes.paginate(:per_page => 6, :page => params[:relationship_page])
      set_selected_relations_common_data('C',nil,"add_cause_btn","causes")
    when "causes"
      @issue_relations = @issue.effects.paginate(:per_page => 6, :page => params[:relationship_page])
      set_selected_relations_common_data('E',nil,"add_effect_btn","effects")
           
    when "is reduced by"
      @issue_relations = @issue.inhibitors.paginate(:per_page => 6, :page => params[:relationship_page])
      set_selected_relations_common_data('I','I',"add_inhibitor_btn","inhibitors")
          
    when "reduces"
      @issue_relations = @issue.inhibiteds.paginate(:per_page => 6, :page => params[:relationship_page])
      set_selected_relations_common_data('R','I',"add_inhibited_btn","inhibiteds")
           
    when "is a subset of"
      @issue_relations = @issue.supersets.paginate(:per_page => 6, :page => params[:relationship_page])
      set_selected_relations_common_data('P','H',"add_superset_btn","supersets")
          
    when "is a superset of"
      @issue_relations = @issue.subsets.paginate(:per_page => 6, :page => params[:relationship_page])
      set_selected_relations_common_data('S','H',"add_subset_btn","subsets")
            
   end
  end

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

  def set_selected_relations_common_data(causality, relationship_type, add_btn_id, causal_sentence)

    @issue_suggestions = @issue.suggestions.where(:causality => causality,:status => 'N')
    @issue_relations.each do |relation|
      if(causality.eql? 'E' or causality.eql? 'R' or causality.eql? 'S')
        @rel_id = Relationship.where(:issue_id=>relation.id, :cause_id=>@issue.id, :relationship_type=>relationship_type).select('id').first.id
        relation.wiki_url = @rel_id 
      else 
        @rel_id = @issue.relationships.where(:cause_id=>relation.id, :relationship_type=>relationship_type).select('id').first.id
        relation.wiki_url = @rel_id 
      end
    end
    @add_btn_id      = add_btn_id
    @causal_sentence = causal_sentence

    if @issue_relations.length < 6
      num_of_suggestions_to_pull = (6 - @issue_relations.length)
      type_of_suggestions        = @causal_sentence          
      retrieve_suggestions(type_of_suggestions, num_of_suggestions_to_pull)
		else
			@suggestions = []
    end  
  end 


  def get_relationship
   
   if params[:rel_id]
      @relationship = Relationship.find(params[:rel_id])
      @rel_references = @relationship.references

			@rel_comments = @relationship.comments

      @rel_issue = Issue.find(@relationship.issue_id)
      @rel_cause = Issue.find(@relationship.cause_id)
      @issue_id = params[:issueid]
      if @issue_id.to_i == @rel_cause.id # then swap!
         @rel_issue, @rel_cause = @rel_cause, @rel_issue  
      end
      @causal_sentence = params[:sentence]
    end

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @issue }
      format.js
      end 
    
  end

  def auto_complete_search
    @search_results = Issue.search(params[:query]).first(5)
      respond_to do |format|
        format.js
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
      # Read in the :type passed with form to recognize Relationship Type
      @causality = params[:action_carrier].to_s
      @causality_id = params[:id_carrier]     
      
      # Check whether or not this Node exist as an issue already?
      # IMPORTANT: Keep the search case-insensitive
      @existing_issue = Issue.where('lower(wiki_url) = ?', @issue.wiki_url.downcase).first
      if !@existing_issue.nil?
        add_already_existent_issue
      else
        add_new_issue
      end
    else
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
			if rel.issue_id == @relationship.issue_id && rel.cause_id == @relationship.cause_id && rel.relationship_type == @relationship.relationship_type
				vs << version
				break
			end
		end

		if current_user && !vs.empty? && vs.last.event.eql?("destroy")
			vs.last.restore
			@notice = "An identical relationship used to exist. It is now reverted back to existence!"
		elsif !current_user && !vs.empty? && vs.last.event.eql?("destroy")
			@notice = "An identical relationship used to exist. Please login to have sufficient privilege to re-create this relationship!"
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
    #@existing_issue = Issue.find(@issueid)
    # if the image selected by the user is different than the one saved then update it.
    if !@existing_issue.nil?
      if @issue.short_url != @existing_issue.short_url 
        @existing_issue.update_attribute(:short_url, @issue.short_url)
      end 
    end
  end

  def add_new_issue
    if @issue.save
      initialize_suggestion_object    

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

  def initialize_suggestion_object
    suggested_causes, suggested_effects, suggested_inhibitors, suggested_reduced, suggested_parents, suggested_subsets = Suggestion.new.get_suggestions(@issue.wiki_url, @issue.id)
    Suggestion.create(suggested_causes)
    Suggestion.create(suggested_effects)
    Suggestion.create(suggested_inhibitors)
    Suggestion.create(suggested_reduced)
    Suggestion.create(suggested_parents)
    Suggestion.create(suggested_subsets) 
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
              else
                "New Issue was created and linked as #{args[1]}"
              end
  end

  def save_relationship
    if @relationship.save
      update_img_if_applicable 
      Reputation::Utils.reputation(:action=>:create, \
                                   :type=>:relationship, \
                                   :id=>@relationship.id, \
                                   :me=>@relationship.user_id, \
                                   :undo=>false, \
                                   :calculate=>true)

      #redirect_to(:back, :notice => @notice)
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
    @notice = @relationship.errors.full_messages.join(", ")
    #redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created') 
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

    if params[:update_image]
      
      @issue.attributes = params[:issue]
      if @issue.save
        @notice = "Image replaced!"
        respond_to do |format|
          format.html 
          format.js {render(:layout=>false, :notice => "Done!")}
        end
      else
        @notice = "Cannot Replace!"
        respond_to do |format|
          format.html 
          format.js {render(:layout=>false, :notice => "Done!")}
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

  # DELETE /issues/1
  # DELETE /issues/1.xml
  def destroy
    @issue = Issue.find(params[:id])
    @called_from = params[:called_from]
    @issue.destroy
    
    Reputation::Utils.reputation(:action=>:destroy, \
                                 :type=>:issue, \
                                 :id=>@issue.id, \
                                 :me=>current_user.id, \
                                 :you=>@issue.user_id, \
                                 :undo=>false, \
                                 :calculate=>false)
    
    
    
    @notice = "Issue Deleted!"
    
    respond_to do |format|
      format.html { redirect_to(:back, :notice => 'Issue was successfully deleted') }
      format.xml  { head :ok }
      format.js
      
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
		if Version.last.id - params[:more].to_i >= 0
			Version.order("created_at DESC").find(:all, :conditions=>["id <= ? AND item_type = ?", Version.last.id - params[:more].to_i, "Relationship"]).each do |version|
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
