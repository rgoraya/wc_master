class MapvisualizationsController < ApplicationController
    
  # GET /mapvisualizations
  def index
    @default_width = 600 #defaults
    @default_height = 400
    @default_border = 50
    @default_node_count = 10 #40
    @default_edge_ratio = 0.2 #0.08
    
    respond_to do |format|
      format.html do #on html calls

        # @vis = Mapvisualization.new(width, height, Relationships.find(:what_nodes_to_get))

        @vis = Mapvisualization.new(:width => @default_width, :height => @default_height, :node_count => @default_node_count, :edge_ratio => @default_edge_ratio) #on new html--generate graph

        session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us
        #flash[:graph]={:width => @vis.width, :height => @vis.height, :nodes => @vis.nodes, :edges => @vis.edges} #@vis #keep the vis for next time (if needed)
        return
      end
      format.js do #respond to ajax calls?
        
        #@vis = Mapvisualization.new(flash[:graph]) #grab the old vis, or make a new one if needed
        @vis = session[:vis] || Mapvisualization.new(:width => @default_width, :height => @default_height, :node_count => @default_node_count, :edge_ratio => @default_edge_ratio) #grab the old vis, or make a new one if needed

        actions = %w[remove_edges foo bar] #etc
        begin
          puts params
          puts "sending "+params[:cmd]
          if params[:args]
            puts "args exists"
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
        
        #flash[:graph]={:width => @vis.width, :height => @vis.height, :nodes => @vis.nodes, :edges => @vis.edges}#@vis #keep the vis for next time
        session[:vis] = @vis
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
