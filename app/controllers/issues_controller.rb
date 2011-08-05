class IssuesController < ApplicationController
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
        if (Relationship.exists?(:cause_id => [@relationship.cause_id], :issue_id=>[@relationship.issue_id]) ||
           Relationship.exists?(:cause_id => [@relationship.issue_id], :issue_id=>[@relationship.cause_id]))
          redirect_to(:back, :notice => 'The Causal link already Exists!')
        else
          if @relationship.save
            redirect_to(:back, :notice => @notice)
          else
            redirect_to(:back, :notice => 'Causal link could not be created')
          end          
        end

          
      
      # * * * * The issue pointing to this wiki_url does not exist so create new issue before relation * * * *
      else
        if @issue.save
          
          # Define a new Relationship
          @relationship = Relationship.new
          
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
            redirect_to(:back, :notice => @notice)
          else
            redirect_to(:back, :notice => 'Causal link could not be created')
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
    @issue.destroy

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
		#@versions = Version.paginate(:page => params[:page], :order => 'created_at DESC')
		
		respond_to do |format|
			format.html
			format.xml 
		end
	end


end
