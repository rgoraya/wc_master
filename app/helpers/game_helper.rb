module GameHelper

  #the code to setup raphael specific for the game; defined here so separate from the drawing .js file (and can be dynamically generated)
  #also includes top-level processing used by the drawing code
  def load_game_raphael
    "var INCREASES = #{MapvisualizationsHelper::INCREASES} //type constants
    var SUPERSET = #{MapvisualizationsHelper::SUPERSET}
    var EXPANDABLE = #{MapvisualizationsHelper::EXPANDABLE}
    var HIGHLIGHTED = #{MapvisualizationsHelper::HIGHLIGHTED}

    var compact = false //for compact drawing; can also pass as a variable if we want
    
    var myPaper, paper, paper_size
    var CANVAS_OFFSET
    window.onload = function(){
    	canvas_container = $('#canvas_container').get(0);
    	paper = myPaper = new Raphael(canvas_container, canvas_container.offsetWidth, canvas_container.offsetHeight) //graphics context
    	paper_size = {width:canvas_container.offsetWidth, height:canvas_container.offsetHeight}
    	CANVAS_OFFSET = $(this.paper.canvas).parent().offset()
      drawInitGame(myPaper);
      drawElements(currNodes, currEdges, myPaper) //call draw on the nodes. These are the ones defined in the helper
    }"
  end

  def javascript_ants
    out = "var my_ants=["

    @ants.each {|ant| out += "new Ant(#{ant.id.to_s},#{ant.plan.to_s},#{ant.island.to_s}),"}

    out += "];"
    
    #puts out
    return out
  end

end
