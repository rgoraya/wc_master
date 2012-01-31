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

      if Issue.exists?(:wiki_url => [@issue.wiki_url])
        add_already_existent_issue
      else
        add_new_issue
        Suggestion.new(params[:issue_id=>@issue.id, :wiki_url=>@issue.wiki_url])  # Suggestions for new issue 
      end
    else
      respond_to do |format|     
        if @issue.save
          initialize_suggestion_object
          format.html { redirect_to(@issue, :notice => 'Issue was successfully created.') }
          format.xml  { render :xml => @issue, :status => :created, :location => @issue }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
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
    @issueid = Issue.where(:wiki_url => @wikiurl).select('id').first.id
  end

  def set_relationship_user_id_if_applicable
    if @issue.user_id.to_s != ""
      @relationship.user_id = @issue.user_id  
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
      @notice = @issue.errors.full_messages
      redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created - Issue did not exist')
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

    if already_exists
      case @causality 
      when "C", "I", "P"
      @relationship.cause_id = @issueid
      @relationship.issue_id = @causality_id 
      when "E", "R", "S"
      @relationship.cause_id = @causality_id
      @relationship.issue_id = @issueid
      end   
      @relationship.relationship_type = args[0].try(:to_s)            
    else
      case @causality 
      when "C", "I", "P"
      @relationship.cause_id = @issue.id
      @relationship.issue_id = @causality_id 
      when "E", "R", "S"
      @relationship.cause_id = @causality_id
      @relationship.issue_id = @issue.id
      end
      @relationship.relationship_type = args[0].try(:to_s)            
    end

    @notice = if already_exists
                "New #{args[2]} linked Successfully"
              else
                "New Issue was created and linked as #{args[1]}"
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
		count = 10
		if params[:segment]
			count = params[:segment].to_i*10
		end
    Version.find(:all, :conditions => ["item_type=?", 'Relationship'], :order=>"created_at DESC").each do |version|

      relationship = version.get_object #should return a Relationshiop object here
      if relationship.issue_id == @issue.id || relationship.cause_id == @issue.id
        @versions << version
      end

			if @versions.length >= count
				break
			end
			
    end
 
    #@versions.sort!{|a,b| b.created_at <=> a.created_at}
		#if params[:segment]
		#	if (params[:segment].to_i-1)*10 <= (@versions.length-1)
		#		@versions = @versions[((params[:segment].to_i-1)*10)..(@versions.length-1)]
		#	else
		#		@versions = []
		#	end
		#end
		#@versions = @versions.paginate(:per_page => 10, :page => params[:page])

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
