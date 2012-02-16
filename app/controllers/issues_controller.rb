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
    
    # Default params to "causes" for initial load
    if params[:rel_type]
      @rel_type = params[:rel_type];
    else
      @rel_type = "is caused by"
    end
    
    case @rel_type

    when "is caused by"
      # get the causes
      @issue_relations = @issue.causes.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_relations.each do |cause|
        @rel_id = @issue.relationships.where(:cause_id=>cause.id, :relationship_type=>nil).select('id').first.id
        cause.wiki_url = @rel_id 
      end
      @add_btn_id = "add_cause_btn"
      @causal_sentence = "causes"
    
    when "causes"
      # get the causes
      @issue_relations = @issue.effects.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_relations.each do |effect|
        @rel_id = Relationship.where(:issue_id=>effect.id, :cause_id=>@issue.id, :relationship_type=>nil).select('id').first.id
        effect.wiki_url = @rel_id 
      end
      @add_btn_id = "add_effect_btn"
      @causal_sentence = "effects"
      
    when "is reduced by"
      # get the causes
      @issue_relations = @issue.inhibitors.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_relations.each do |inhibitor|
        @rel_id = @issue.relationships.where(:cause_id=>inhibitor.id, :relationship_type=>'I').select('id').first.id
        inhibitor.wiki_url = @rel_id 
      end
      @add_btn_id = "add_inhibitor_btn"
      @causal_sentence = "inhibitors"
          
    when "reduces"
      # get the inhibiteds
      @issue_relations = @issue.inhibiteds.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_relations.each do |inhibited|
        @rel_id = Relationship.where(:issue_id=>inhibited.id, :cause_id=>@issue.id, :relationship_type=>'I').select('id').first.id
        inhibited.wiki_url = @rel_id 
      end
      @add_btn_id = "add_inhibited_btn"
      @causal_sentence = "inhibiteds"
      
    when "is a subset of"
      # get the causes
      @issue_relations = @issue.supersets.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_relations.each do |superset|
        @rel_id = @issue.relationships.where(:cause_id=>superset.id, :relationship_type=>'H').select('id').first.id
        superset.wiki_url = @rel_id 
      end
      @add_btn_id = "add_superset_btn"
      @causal_sentence = "supersets"
    
    when "is a superset of"
      # get the subsets
      @issue_relations = @issue.subsets.paginate(:per_page => 6, :page => params[:relationship_page])
      # insert relationship_id
      @issue_relations.each do |subset|
        @rel_id = Relationship.where(:issue_id=>subset.id, :cause_id=>@issue.id, :relationship_type=>'H').select('id').first.id
        subset.wiki_url = @rel_id 
      end
      @add_btn_id = "add_subset_btn"
      @causal_sentence = "subsets"
      
   end

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

    @issue_cause_suggestion = @issue.suggestions.where(:causality => 'C',:status => 'N')
    @issue_effect_suggestion = @issue.suggestions.where(:causality => 'E',:status => 'N')
    @issue_inhibitor_suggestion = @issue.suggestions.where(:causality => 'I',:status => 'N')
    @issue_inhibited_suggestion = @issue.suggestions.where(:causality => 'R',:status => 'N')
    @issue_parent_suggestion = @issue.suggestions.where(:causality => 'P',:status => 'N')
    @issue_subset_suggestion = @issue.suggestions.where(:causality => 'S',:status => 'N')    

    @references = Issue.rel_references(params[:rel_id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue }
      format.js
     
    end
  end

  def get_relationship
   
   if params[:rel_id]
      @relationship = Relationship.find(params[:rel_id])
      @rel_references = @relationship.references
      @rel_issue = Issue.find(@relationship.issue_id)
      @rel_cause = Issue.find(@relationship.cause_id)
      @issue_id = params[:issueid]
      if @issue_id.to_i == @rel_cause.id # then swap!
         @rel_issue, @rel_cause = @rel_cause, @rel_issue  
      end
      @causal_sentence = params[:sentence]
    end

    respond_to do |format|
      format.html { render :layout=>"issues/get_relationship"}
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
        Suggestion.new(params[:issue_id=>@issue.id, :wiki_url=>@issue.wiki_url])  # Suggestions for new issue 
      end
    else
      respond_to do |format|     
        if @issue.save
          initialize_suggestion_object

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
    save_relationship  
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
      save_relationship
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
