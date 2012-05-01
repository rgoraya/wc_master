module GameHelper

  #the code to setup raphael specific for the game; defined here so separate from the drawing .js file (and can be dynamically generated)
  #also includes top-level processing used by the drawing code
  def load_game_raphael
    "var INCREASES = #{MapvisualizationsHelper::INCREASES}; //type constants
    var SUPERSET = #{MapvisualizationsHelper::SUPERSET};
    var EXPANDABLE = #{MapvisualizationsHelper::EXPANDABLE};
    var HIGHLIGHTED = #{MapvisualizationsHelper::HIGHLIGHTED};

    var player_id = #{@game_user}
    var HOME = #{@home_island};
    var continuous = #{@continuous.to_s};
    
    var myPaper, paper, paper_size;
    var CANVAS_OFFSET;
    window.onload = function(){
    	canvas_container = $('#canvas_container').get(0);
    	paper = myPaper = new Raphael(canvas_container, canvas_container.offsetWidth, canvas_container.offsetHeight); //graphics context
    	paper_size = {width:canvas_container.offsetWidth, height:canvas_container.offsetHeight};
    	CANVAS_OFFSET = $(this.paper.canvas).parent().offset(); 
      drawElements(currNodes, currEdges, myPaper); //call draw on the nodes. These are the ones defined in the helper
      drawInitGame(myPaper);
      initIslands();
    }"
  end

  def javascript_ants
    out = "["
    @ants.each {|ant| out += "new Ant(#{ant.id.to_s},#{ant.plan.to_s},#{ant.island.to_s}),"}
    out += "];"
    #puts out
    return out
  end

  def javascript_correctness(correct)
    # pull out degree and wrongness rubric
    degree = correct.delete('degree')
    wrong = correct.delete('wrong')

    #clean up correctness matrix (get rid of empty values)
    correct.each_key do |i| 
      correct[i] = correct[i].each_key{|j| correct[i][j] = correct[i][j].reject{|k,v| v <= 0}}
      correct[i].delete_if{|j,v| v.empty?}
    end
    correct.delete_if{|i,v| v.empty?}
    # puts "correct: "+correct.to_s
    
    out = "var yes={"
    correct.each_key do |i|
      out += "#{i-1}:{"
      correct[i].each_key do |j|
        out += "#{j-1}:{"
        correct[i][j].each do |k,v|
          out += "'#{k}':#{v},"
        end
        out = out[0...-1]
        out += "},"
      end
      out = out[0...-1]
      out += "},"
    end
    out = out[0...-1]
    out += ",w:"+(Game::RUBRIC[-1*Game::DEGREE] || Game::RUBRIC[0]).to_s
    out += "};"

    #puts out
    return out
  end

  # is this its own method? or do we do this in javascript?
  def javascript_islands(nodes, optimal_degrees)
    out = "var islands={"
    nodes.each_value {|node| out += "#{node.id}:new Island(#{node.id},#{optimal_degrees[node.id]}),"}
    out += "};"

    # puts out
    return out
  end

end
