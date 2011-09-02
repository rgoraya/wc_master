class SuggestionsController < ApplicationController
  # GET /suggestions
  # GET /suggestions.xml
  def index
    @suggestions = Suggestion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @suggestions }
    end
  end

  # GET /suggestions/1
  # GET /suggestions/1.xml
  def show
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @suggestion }
    end
  end

  # GET /suggestions/new
  # GET /suggestions/new.xml
  def new
    @suggestion = Suggestion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @suggestion }
    end
  end

  # GET /suggestions/1/edit
  def edit
    @suggestion = Suggestion.find(params[:id])
  end

  # POST /suggestions
  # POST /suggestions.xml
  def create
    
    @suggestion = Suggestion.new(params[:suggestion])

    @suggested_causes, @suggested_effects = @suggestion.get_suggestions(@suggestion.wiki_url, @suggestion.issue_id)

    #@suggested_causes.each do |cause|
    #  @suggestion = Suggestion.new(params[:title=>cause[:title],:wiki_url=>cause[:wiki_url],:causality=>cause[:causality],:status=>cause[:status],:issue_id=>cause[:issue_id]])
    #  @suggestion.save
    #end

    #@suggested_effects.each do |effect|
    #  @suggestion = Suggestion.new(params[:title=>effect[:title],:wiki_url=>effect[:wiki_url],:causality=>effect[:causality],:status=>effect[:status],:issue_id=>effect[:issue_id]])
    #  @suggestion.save
    #end

    Suggestion.create(@suggested_causes)
    Suggestion.create(@suggested_effects)

    respond_to do |format|
      if  @suggested_causes.count > 0 ||  @suggested_effects.count > 0
        format.html { redirect_to(:back, :notice => @suggested_causes.count.to_s + ' causes and ' + @suggested_effects.count.to_s + ' effects were suggested!') }
        format.xml  { render :xml => @suggestion, :status => :created, :location => @suggestion }
      else
        format.html { redirect_to(:back, :notice => 'No new suggestions were found.') }
        format.xml  { render :xml => @suggestion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /suggestions/1
  # PUT /suggestions/1.xml
  def update
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      if @suggestion.update_attributes(params[:suggestion])
        @notice = "Suggestion was successfully updated."
        @suggestion.status_changed?
        @notice = "Suggestion rejected!"
        
        format.html { redirect_to(:back, :notice => @notice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @suggestion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /suggestions/1
  # DELETE /suggestions/1.xml
  def destroy
    @suggestion = Suggestion.find(params[:id])
    @suggestion.destroy

    respond_to do |format|
      format.html { redirect_to(suggestions_url) }
      format.xml  { head :ok }
    end
  end

end
