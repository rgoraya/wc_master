class GameController < ApplicationController
  layout "game_layout" #don't use normal headers and such for now...

  @@DEFAULT_WIDTH = 900#900*1.0 #defaults
  @@DEFAULT_HEIGHT = 500#675*1.0
  # for large map, 900x900 looks good
  @@DEFAULT_BORDER = 50

	log_path = nil
	if (Rails.env.development? || Rails.env.test?)
  	log_path = "log/game_log.txt"
	elsif Rails.env.production?
		log_path = "/u/apps/production/wikicausality/shared/log/game_log.txt"
	end
	File.new(log_path, "w") unless File.exist?(log_path)

	@@GAME_LOG = Logger.new(log_path)

  def index
    render 'welcome.html.haml'
  end

  def welcome
  end

  def how_to_play
  end

  def article
  end

  def play
		@time_stamp = DateTime.current.strftime("%Y%m%d%H%M%S%L")

    @default_width = @@DEFAULT_WIDTH
    @default_height = @@DEFAULT_HEIGHT
    @default_border = @@DEFAULT_BORDER
    
    # @verbose = false #unless specified otherwise in params
    @verbose = !params[:v].nil?
    #puts "verbose: "+@verbose.to_s
    @continuous = !params[:c].nil? #continuous = false unless otherwise specified. Eventually will be randomly determined

    # puts "===Controller Params==="
    # puts params
    
    respond_to do |format|
      format.html do #on html calls
        if params[:expert]
          @game = Game.new(:width => @default_width, :height => @default_height, :expert => params[:expert])
        else
          @game = Game.new(:width => @default_width, :height => @default_height, :blank => true)
        end

        @home_island = @game.home
        
        puts "***** HOME ISLAND *****", @home_island

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
    
        #@game = Game.new(:width => @default_width, :height => @default_height, :edges => params[:edges] || Hash.new())
        
        #@result = @game.compare_to_expert.to_s
        #@ants = @game.get_ants
        
        # flash[:notice] = 'Your score: '+@result.to_s
      
        
      end
    end
  end

	def log
		@@GAME_LOG.info([params[:time_stamp], DateTime.current.strftime("%Y%m%d%H%M%S%L"),params[:data],(current_user ? current_user.id : "nil")].join("|"))
		render :nothing => true
	end

  def research
    #the introductory paragraph
    
  end

  def survey_demographic
    @user_id = 'random_id_should_be_made_here'
    ## show survey
    ## on submit, should redirect to game
  end

  def survey_evaluation
    ## show the survey, etc
  end

end
