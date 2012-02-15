class MapvisualizationsController < ApplicationController
    
  # GET /mapvisualizations
  def index
    @default_width = 900*0.8 #defaults
    @default_height = 675*0.8
    # for large map, 900x900 looks good
    @default_border = 50
    @default_node_count = 5 #40
    @default_edge_ratio = 0.5 #0.08

    # puts "===Controller Params==="
    # puts params
    
    respond_to do |format|
      format.html do #on html calls

        @vis = Mapvisualization.new(:width => @default_width, :height => @default_height, 
          :node_count => @default_node_count, :edge_ratio => @default_edge_ratio, 
          :params => {:query => params[:q],:issue_list => params[:i]}) #on new html--generate graph

        session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us (forever)
        return
      end


      format.js do #respond to ajax calls

        @vis = session[:vis] || Mapvisualization.new(:width => @default_width, :height => @default_height, 
          :node_count => @default_node_count, :edge_ratio => @default_edge_ratio, 
          :params => {:query => params[:q],:issue_list => params[:i]}) #grab the old vis, or make a new one if needed

        puts "===format.js params===",params
        
        if params[:do] == 'get_issue'
          issue_to_show = Issue.find(params[:id])
          # @popup_pos = "some position"
          render :partial => "issue_modal", :content_type => 'text/html', 
            :locals => {:issue => issue_to_show, :location => [params[:x],params[:y]]}

        elsif params[:do] == 'get_relation'
          relation_to_show = Relationship.find(params[:id])
          render :partial => "relation_modal", :content_type => 'text/html', 
            :locals => {:relation => relation_to_show, :location => [params[:x],params[:y]], :curve => params[:curve]}
                
        elsif params[:layout_cmd]
          actions = %w[remove_edges foo bar] #etc
          begin
            puts "sending "+params[:layout_cmd]
            if params[:args]
              @vis.send(params[:layout_cmd], params[:args]) #if ACTIONS.include?(params[:layout_cmd])
            else
              @vis.send(params[:layout_cmd]) #if ACTIONS.include?(params[:layout_cmd])
            end
          rescue NoMethodError
            flash[:error] = 'No such layout command'
          end
        end

        session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us (forever)
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
