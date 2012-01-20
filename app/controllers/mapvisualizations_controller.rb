class MapvisualizationsController < ApplicationController

  # GET /mapvisualizations
  def index
    width = 500 #defaults
    height = 500
    node_count = 10

    respond_to do |format|
      format.html do #on html calls

        @vis = Mapvisualization.new(:width => width, :height => height, :node_count => node_count) #on new html--generate graph

        session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us
        #flash[:graph]={:width => @vis.width, :height => @vis.height, :nodes => @vis.nodes, :edges => @vis.edges} #@vis #keep the vis for next time (if needed)
        return
      end
      format.js do #respond to ajax calls?

        #@vis = Mapvisualization.new(flash[:graph]) #grab the old vis, or make a new one if needed
        @vis = session[:vis] || Mapvisualization.new(:width => width, :height => height, :node_count => node_count) #grab the old vis, or make a new one if needed

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

end
