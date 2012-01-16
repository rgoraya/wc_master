class MapvisualizationsController < ApplicationController
  
  # GET /mapvisualizations
  def index
    
    respond_to do |format|
      format.html do #on html calls
        width = 500 #defaults
        height = 500
        node_count = 10

        @vis = Mapvisualization.new(width, height, node_count) #on new html--generate graph

        flash[:graph]=@vis #keep the vis for next time (if needed)
        return
      end
      format.js do #respond to ajax calls?
        @vis = flash[:graph] || Mapvisualization.new(node_count) #grab the old vis, or make a new one if needed

        actions = %w[remove_edges foo bar] #etc
        begin
          puts "sending "+params[:cmd]
          if params[:args]
            @vis.send(params[:cmd], params[:args]) #if ACTIONS.include?(params[:cmd])
          else
            @vis.send(params[:cmd]) #if ACTIONS.include?(params[:cmd])
          end
        rescue NoMethodError
          flash[:error] = 'No such layout command'
        end
        
        #this throws an error if the command isn't actually in the model; not sure how to catch
          # case params[:cmd] #do whatever the given command was
          # when "remove_edges"
          #   @vis.remove_edges #call the method we want!!
          # end
        
        flash[:graph]=@vis #keep the vis for next time
        return
      end
    end
  
  end


############################################################
### OLD RESTFUL METHODS
############################################################

  # # GET /mapvisualizations/1
  # # GET /mapvisualizations/1.xml
  # def show
  #   @mapvisualization = Mapvisualization.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @mapvisualization }
  #   end
  # end
  # 
  # # GET /mapvisualizations/new
  # # GET /mapvisualizations/new.xml
  # def new
  #   @mapvisualization = Mapvisualization.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @mapvisualization }
  #   end
  # end
  # 
  # # GET /mapvisualizations/1/edit
  # def edit
  #   @mapvisualization = Mapvisualization.find(params[:id])
  # end
  # 
  # # POST /mapvisualizations
  # # POST /mapvisualizations.xml
  # def create
  #   @mapvisualization = Mapvisualization.new(params[:mapvisualization])
  # 
  #   respond_to do |format|
  #     if @mapvisualization.save
  #       format.html { redirect_to(@mapvisualization, :notice => 'Mapvisualization was successfully created.') }
  #       format.xml  { render :xml => @mapvisualization, :status => :created, :location => @mapvisualization }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @mapvisualization.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # PUT /mapvisualizations/1
  # # PUT /mapvisualizations/1.xml
  # def update
  #   @mapvisualization = Mapvisualization.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @mapvisualization.update_attributes(params[:mapvisualization])
  #       format.html { redirect_to(@mapvisualization, :notice => 'Mapvisualization was successfully updated.') }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @mapvisualization.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # DELETE /mapvisualizations/1
  # # DELETE /mapvisualizations/1.xml
  # def destroy
  #   @mapvisualization = Mapvisualization.find(params[:id])
  #   @mapvisualization.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(mapvisualizations_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
