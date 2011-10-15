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

    @suggested_causes, @suggested_effects, @suggested_inhibitors, @suggested_reduced, @suggested_parents, @suggested_subsets = @suggestion.get_suggestions(@suggestion.wiki_url, @suggestion.issue_id)

    Suggestion.create(@suggested_causes)
    Suggestion.create(@suggested_effects)
    Suggestion.create(@suggested_inhibitors)
    Suggestion.create(@suggested_reduced)
    Suggestion.create(@suggested_parents)
    Suggestion.create(@suggested_subsets)


    respond_to do |format|
      if  @suggested_causes.count > 0 ||  @suggested_effects.count > 0 || @suggested_inhibitors.count > 0 || @suggested_reduced.count > 0 || @suggested_parents.count > 0 || @suggested_subsets.count > 0
        format.html { redirect_to(:back, :notice => @suggested_causes.count.to_s + ' causes, ' + 
                                                    @suggested_effects.count.to_s + ' effects, ' +
                                                    @suggested_inhibitors.count.to_s + ' inhibitors, ' +
                                                    @suggested_reduced.count.to_s + ' inhibited, ' +
                                                    @suggested_parents.count.to_s + ' supersets, ' + 
                                                    @suggested_subsets.count.to_s + ' subsets were suggested '
        
        ) }
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
