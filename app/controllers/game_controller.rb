class GameController < ApplicationController
  layout "game_layout" #don't use normal headers and such for now...

  @@DEFAULT_WIDTH = 900#900*1.0 #defaults
  @@DEFAULT_HEIGHT = 600#675*1.0
  # for large map, 900x900 looks good

  @@DEFAULT_BORDER = 50

	@@GAME_LOG = Logger.new("/home/duyet/Desktop/log.txt")

  def index

    @default_width = @@DEFAULT_WIDTH
    @default_height = @@DEFAULT_HEIGHT
    @default_border = @@DEFAULT_BORDER
    
    # @verbose = false #unless specified otherwise in params
    @verbose = !params[:v].nil?
    #puts "verbose: "+@verbose.to_s

    # puts "===Controller Params==="
    # puts params
    
    respond_to do |format|
      format.html do #on html calls
        if params[:expert]
          @vis = Game.new(:width => @default_width, :height => @default_height, :expert => params[:expert])
        else
          @vis = Game.new(:width => @default_width, :height => @default_height, :blank => true)
        end

        # flash[:notice] = @vis.notice
        # 
        # session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us (forever)
        return
      end

      format.js do #respond to ajax calls
        puts "*** HANDLING GAME AJAX ***"
        puts params

        return
      end
    end
  end


  def run #everything is handled as JS for this
    @default_width = @@DEFAULT_WIDTH
    @default_height = @@DEFAULT_HEIGHT
    @default_border = @@DEFAULT_BORDER

    # puts "**** RUNNING PARAMETERS ****"
    # puts params
    # puts params[:edges] ## this is the edges that the user created

    respond_to do |format|
      format.js do #respond to ajax calls
    
        @game = Game.new(:width => @default_width, :height => @default_height, :edges => params[:edges] || Hash.new())
        @result = @game.compare_to_expert.to_s
        @ants = @game.get_ants
        
        # flash[:notice] = 'Your score: '+@result.to_s
        
        
      end
    end
  end

	def log
		@@GAME_LOG.info([session[:vis], DateTime.current.strftime("%Y%m%d%H%M%S%L"),params[:data],(current_user ? current_user.id : "nil")].join("|"))
		render :nothing => true
	end

  #temporary
  def edge_qtip
    render :partial => "edge_qtip", :content_type => 'text/html', :locals => {:edge => params[:edge]}
  end

end
