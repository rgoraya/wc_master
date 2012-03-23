class RelationshipsController < ApplicationController

  # GET /relationships
  # GET /relationships.xml
  def index

      if (params[:sort_by])
        @sort_by = params[:sort_by]  
      else 
        @sort_by = "Most recent" 
      end

      case @sort_by
        when "Most recent"  
          @relationships = Relationship.find(:all, :order=>"updated_at DESC").paginate(:per_page => 20, :page => params[:page])
        when "Reference count"
          @relationships = Relationship.find(:all, :order=>"references_count DESC").paginate(:per_page => 20, :page => params[:page])
      end

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.xml  { render :xml => @relationships }
    end
  end

  # GET /relationships/1
  # GET /relationships/1.xml
  def show
    @relationship = Relationship.find(params[:id])
    
    @rel_references = @relationship.references
    
    @rel_issue = Issue.find(@relationship.issue_id)
    
    @rel_cause = Issue.find(@relationship.cause_id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml    => @relationship }
      format.js
    end
  end

  # GET /relationships/new
  # GET /relationships/new.xml
  def new
    @relationship = Relationship.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @relationship }
    end
  end

  # GET /relationships/1/edit
  def edit
    @relationship = Relationship.find(params[:id])
  end

  # POST /relationships
  # POST /relationships.xml
  def create
    @relationship = Relationship.new(params[:relationship])

    respond_to do |format|
      if @relationship.save
        format.html { redirect_to(@relationship, :notice => 'Relationship was successfully created.') }
        format.xml  { render :xml => @relationship, :status => :created, :location => @relationship }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /relationships/1
  # PUT /relationships/1.xml
  def update
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      if @relationship.update_attributes(params[:relationship])
        format.html { redirect_to(@relationship, :notice => 'Relationship was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.xml
  def destroy
    @relationship = Relationship.find(params[:id])
		version = Version.find(:last, :conditions=>["item_type = ? AND item_id = ?", "Relationship", @relationship.id])
		if version.event.eql?("create") && !version.reverted_from.nil?
			version.restore
		else
			@relationship.destroy
			Reputation::Utils.reputation(:action=>:destroy, \
																		:type=>:relationship, \
																		:id=>@relationship.id, \
																		:me=>current_user.id, \
																		:you=>@relationship.user_id, \
																		:undo=>false, \
																		:calculate=>true)
		end

    @notice = "Relationship Deleted!"
    respond_to do |format|
      format.html { redirect_to(:back,:notice => 'Causal link was successfully deleted.' ) }
      format.xml  { head :ok }
      format.js
    end
  end
end
