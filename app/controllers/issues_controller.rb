class IssuesController < ApplicationController

	@@mutex=Mutex.new

  # GET /issues
  # GET /issues.xml
  def index
    @issues = Issue.search(params[:search]).paginate(:per_page => 5, :page => params[:page])

    respond_to do |format|
      format.js {render :layout=>false}
      format.html # index.html.erb
      format.xml  { render :xml => @issues }
    end
  end
  
  # GET /issues/1
  # GET /issues/1.xml
  def show
    @issue = Issue.find(params[:id])

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
    if params[:save_issue_rel_button]

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
          @notice = 'New Cause linked Successfully'
        end
        
        # It is an Effect
        if @causality == "E"
          @relationship.cause_id = @causality_id
          @relationship.issue_id = @issueid      
          @notice = 'New Effect linked Successfully'
        end
        
        # Save the Relationship     
        if @relationship.save

					RepManagement::Utils.reputation(:action=>:create, :type=>:relationship, :id=>@relationship.id, :me=>@relationship.user_id, :calculate=>true)

          redirect_to(:back, :notice => @notice)
        else
          @notice = @relationship.errors.full_messages
          redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created')
        end
      
      # * * * * The issue pointing to this wiki_url does not exist so create new issue before relation * * * *
      else
        if @issue.save
          
					RepManagement::Utils.reputation(:action=>:create, :type=>:issue, :me=>@issue.user_id, :calculate=>true)

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
          
          # It is an Effect
          if @causality == "E"  
            @relationship.cause_id = @causality_id
            @relationship.issue_id = @issue.id
            @notice = 'New Issue was created and linked as an effect'
          end          
            
          # Save the Relationship     
          if @relationship.save

						RepManagement::Utils.reputation(:action=>:create, :type=>:relationship, :id=>@relationship.id, :me=>@relationship.user_id, :calculate=>true)

            redirect_to(:back, :notice => @notice)
          else
            @notice = @relationship.errors.full_messages
            redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created')
          end
        
        # some problem occurred and the Issue could not be saved
        else
          @notice = @issue.errors.full_messages
          redirect_to(:back, :notice => @notice.to_s + ' Causal link was not created')
          
        end
        
      end
      
         
    else
      
     respond_to do |format|     
        if @issue.save
          format.html { redirect_to(@issue, :notice => 'Issue was successfully created.') }
          format.xml  { render :xml => @issue, :status => :created, :location => @issue }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
        end
      end      
    end
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
    @@mutex.synchronize{
    	@issue.destroy
			who = Version.find(:first, :conditions=>["item_type=? AND item_id=?", 'Issue', @issue.id]).sibling_versions.last.whodunnit
			RepManagement::Utils.reputation(:action=>:destroy, :type=>:issue, :id=>@issue.id, :me=>who, :you=>@issue.user_id, :calculate=>false)
		}
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
		Version.find(:all, :conditions => ["item_type = 'Relationship'"]).each do |version|
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
