class GameController < ApplicationController
  layout "game_layout" #don't use normal headers and such for now...

  def index
    @default_width = 900#900*1.0 #defaults
    @default_height = 600#675*1.0
    # for large map, 900x900 looks good
    @default_border = 50
    
    # @verbose = false #unless specified otherwise in params
    @verbose = !params[:v].nil?
    #puts "verbose: "+@verbose.to_s

    # puts "===Controller Params==="
    # puts params
    
    respond_to do |format|
      format.html do #on html calls
        @vis = Game.new(:width => @default_width, :height => @default_height, :params => params) #Just pass in all the params for handling

        flash[:notice] = @vis.notice
        
        session[:vis] = @vis #we want to not use sessions for storage as soon as we have a db backing us (forever)
        return
      end

      format.js do #respond to ajax calls
        puts "handling ajax"
        return
      end
    end
  end


end