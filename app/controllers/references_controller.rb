class ReferencesController < ApplicationController


  # GET /references
  # GET /references.xml
  def index
    @references = Reference.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @references }
    end
  end

  # GET /references/1
  # GET /references/1.xml
  def show
    @reference = Reference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reference }
    end
  end

  # GET /references/new
  # GET /references/new.xml
  def new
    @reference = Reference.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reference }
    end
  end

  # GET /references/1/edit
  def edit
    @reference = Reference.find(params[:id])
  end

  # POST /references
  # POST /references.xml
  def create
    @reference = Reference.new(params[:reference])
    
    @relationship = Relationship.find(@reference.relationship_id)
    
    respond_to do |format|
      if @reference.save

        format.html { redirect_to(:back, :notice => 'Reference was successfully added.') }
        format.xml  { render :xml => @reference, :status => :created, :location => @reference }
        format.js
      else
        @notice = @reference.errors
        format.html { redirect_to(:back, :notice => @reference.errors) }
        format.xml  { render :xml => @reference.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /references/1
  # PUT /references/1.xml
  def update
    @reference = Reference.find(params[:id])

    respond_to do |format|
      if @reference.update_attributes(params[:reference])
        format.html { redirect_to(@reference, :notice => 'Reference was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /references/1
  # DELETE /references/1.xml
  def destroy
    @reference = Reference.find(params[:id])
    
    @relationship = Relationship.find(@reference.relationship_id)

    @reference.destroy

		#Version.destroy_all(["item_type = ? AND item_id = ?", "Reference", @reference.id])

    @refnotice = "Reference Deleted!"
    respond_to do |format|
      format.html { redirect_to(references_url) }
      format.xml  { head :ok }
      format.js
    end
  end
end
