class GameController < ApplicationController
  layout "game_layout" #don't use normal headers and such for now...

  @@DEFAULT_WIDTH = 900#900*1.0 #defaults
  @@DEFAULT_HEIGHT = 600#675*1.0
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

  def play
    @game_user = session[:game_user] || params[:player] || rand(1000000000)
    session[:game_user] = @game_user
    puts @game_user
		@time_stamp = DateTime.current.strftime("%Y%m%d%H%M%S%L")

    @default_width = @@DEFAULT_WIDTH
    @default_height = @@DEFAULT_HEIGHT
    @default_border = @@DEFAULT_BORDER
    
    # @verbose = false #unless specified otherwise in params
    @verbose = !params[:v].nil?

    @continuous = params[:c] ? (params[:c]=='1') : (@game_user%2==0) #either as specified or random otherwise

    respond_to do |format|
      format.html do #on html calls
        if params[:expert]
          @game = Game.new(:width => @default_width, :height => @default_height, :expert => params[:expert])
        else
          @game = Game.new(:width => @default_width, :height => @default_height, :blank => true)
        end

        @home_island = @game.home
        # puts "***** HOME ISLAND *****", @home_island
        return
      end

      format.js do #respond to ajax calls
        puts "*** HANDLING GAME AJAX ***"
        puts params
        return
      end
    end
  end

	def log
	  entry = [params[:player],DateTime.current.strftime("%Y%m%d%H%M%S%L"),params[:data]].join("|")
	  puts entry
		@@GAME_LOG.info(entry)
		render :nothing => true
	end

  def research
    @game_user = session[:game_user] || params[:player] || rand(1000000000)
    session[:game_user] = @game_user
    puts @game_user
  end

  def index
    welcome
    render 'welcome.html.haml'
  end

  def welcome
    @game_user = session[:game_user] || params[:player] || rand(1000000000)
    session[:game_user] = @game_user
    puts @game_user
  end

  def how_to_play
    @game_user = session[:game_user] || params[:player] || rand(1000000000)
    session[:game_user] = @game_user
    puts @game_user
  end

  def article
    @game_user = session[:game_user] || params[:player] || rand(1000000000)
    session[:game_user] = @game_user
    puts @game_user
  end


  def survey_demographic
    @game_user = rand(1000000000)
    session[:game_user] = @game_user
  end

  def survey_evaluation
    @game_user = session[:game_user] || params[:player]
    session[:game_user] = @game_user
  end
  
  def thank_you #redirect after evaluation is completed
    @game_user = session[:game_user] || params[:player]
    session[:game_user] = @game_user
  end

end
