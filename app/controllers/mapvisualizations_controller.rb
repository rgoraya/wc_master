class MapvisualizationsController < ApplicationController

  def index
    @default_width = 600#900*1.0 #defaults
    @default_height = 600#675*1.0
    # for large map, 900x900 looks good
    @default_border = 50
    @default_node_count = 3 #40
    @default_edge_ratio = 0.5 #0.08
    
    # @verbose = false #unless specified otherwise in params
    @verbose = !params[:v].nil?
    #puts "verbose: "+@verbose.to_s

    # puts "===Controller Params==="
    # puts params
    
    respond_to do |format|
      format.html do #on html calls
        @vis = Mapvisualization.new(:width => @default_width, :height => @default_height, 
          :node_count => @default_node_count, :edge_ratio => @default_edge_ratio, 
          :params => params) #on new html--generate graph. Just pass in all the params for handling

        flash[:notice] = @vis.notice
        
        session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us (forever)
        return
      end

      format.js do #respond to ajax calls
        @vis = session[:vis] || Mapvisualization.new(:width => @default_width, :height => @default_height, 
          :node_count => @default_node_count, :edge_ratio => @default_edge_ratio, 
          :params => {:query => params[:q],:id_list => params[:i]}) #grab the old vis, or make a new one if needed

        puts "===format.js params===",params
        
        if params[:do] == 'get_issue'
          issue_to_show = Issue.find(params[:id])
          # @popup_pos = "some position"
          render :partial => "issue_modal_small", :content_type => 'text/html', 
            :locals => {:issue => issue_to_show, :location => [params[:x],params[:y]]}

        elsif params[:do] == 'get_relation'
          relation_to_show = Relationship.find(params[:id])
          render :partial => "relation_modal_small", :content_type => 'text/html', 
            :locals => {:relation => relation_to_show, :location => [params[:x],params[:y]], :curve => params[:curve]}
        
        elsif params[:do] == 'goto_issue'
          @vis = Mapvisualization.new(:width => @default_width, :height => @default_height, :params => {:q => 'show', :i => params[:target]})
          render "index.js.erb"
          
        elsif params[:do] == 'goto_relationship'
          @vis = Mapvisualization.new(:width => @default_width, :height => @default_height, :params => {:q => 'show', :r => params[:target]})
        
        elsif params[:do] == 'goto_path'
          @vis = Mapvisualization.new(:width => @default_width, :height => @default_height, :params => {:q => 'path', :from => params[:from], :to => params[:to]})
          render "index.js.erb"
        
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
            flash[:notice] = 'No such layout command'
          end
        end

        flash[:notice] = @vis.notice
        
        session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us (forever)
        return
      end
    end
  end

  def search_bars
    puts "\n**********************************************************"
    puts "************* GOT TO SEARCH_BARS CONTROLLER **************"
    puts "**********************************************************"
    puts params
    
    respond_to do |format|
      format.js do
        unless params[:selected_data].empty?
          new_issue_id = params[:selected_data].slice(/\d+/)
          
          if params[:display_area_id] == 'vis_cause_issue_search'
            if params[:effect_id].empty?
              params[:do] = 'goto_issue'
              params[:target] = new_issue_id
            elsif
              params[:do] = 'goto_path'
              params[:from] = new_issue_id
              params[:to] = params[:effect_id]
            end
          elsif params[:display_area_id] == 'vis_effect_issue_search'
            ##should always have a cause value, so don't need to handle (in theory)...
            params[:do] = 'goto_path'
            params[:from] = params[:cause_id]
            params[:to] = new_issue_id            
          end
                    
          index #call index, which will do the rest of the work
        else
          @search_results = Issue.search(params[:query]).first(5) #get some search results, and render
        end
      end

        # format.html do
        #   #@issues = Issue.search(params[:query])
        #   redirect_to :controller => 'issues', :action => 'index', :search => params[:query]
        #   #redirect_to(:issues, params[:query] )
        # end
      end 
  end

  def qtip
    if params[:t] == 'issue'
      issue_to_show = Issue.find(params[:id])
      render :partial => "issue_qtip", :content_type => 'text/html', :locals => {:issue => issue_to_show}
    elsif params[:t] == 'relation'
      relation_to_show = Relationship.find(params[:id])
      render :partial => "relation_qtip", :content_type => 'text/html', :locals => {:relation => relation_to_show}
    end
  end

end