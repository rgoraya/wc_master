module MapvisualizationsHelper

  #gets the names of major variables used in javascript functions
  def js_names
    nodes_name = 'currNodes'
    edges_name = 'currEdges'
    paper_name = 'myPaper'
  end

  #helper method to print the nodes and edges as javascript arrays, now with empty-set handling!
  def javascript_graph(nodes, edges, adjacency, nodes_name='currNodes', edges_name='currEdges')
    out = ""
    if nodes.length > 0
      out += "var "+nodes_name+"={"+
        nodes.map {|k,n| n.js_k + ":" + n.js(@default_border)} .join(',')+
        ",keys:["+ nodes.map {|k,n| n.js_k} .join(',') +"]"+
        "};"
    else
      out += "var "+nodes_name+"={keys:[]};"
    end
      
    if edges.length > 0
      multi_edge = Hash[edges.group_by {|e| [e.a.id,e.b.id].sort}.map {|k,v| [k,v.count]}] #number edges per nodeset

      counters = Hash.new(0)
      out += "var "+edges_name+"={"+
        edges.map {|e| e.js_k + ":" + e.js(nodes_name, 
          multi_edge[[e.a.id,e.b.id].sort] == 1 ? 0 : (e.a.id < e.b.id ? 1 : -1)*(counters[ [e.a.id,e.b.id].sort ] += 1))
          }.join(',')+
        ",keys:["+ edges.map {|e| e.js_k} .join(',') +"]"+
        "};"
    else
      out += "var "+edges_name+"={keys:[]};"
    end
    puts out
    return out      
  end

  #the code to setup raphael; defined here so separate from the drawing .js file (and can be dynamically generated)
  #also includes top-level processing used by the drawing code
  def load_raphael(compact=false)
    "var INCREASES = #{Mapvisualization::Edge::INCREASES} //type constants
    var SUPERSET = #{Mapvisualization::Edge::SUPERSET}
    var EXPANDABLE = #{Mapvisualization::Edge::EXPANDABLE}
    var HIGHLIGHTED = #{Mapvisualization::Edge::HIGHLIGHTED}

    var compact = #{compact.to_s} //for compact drawing; can also pass as a variable if we want
    
    var myPaper
      window.onload = function(){
    	myPaper = new Raphael(document.getElementById('canvas_container'), document.getElementById(\"canvas_container\").offsetWidth, document.getElementById(\"canvas_container\").offsetHeight) //graphics context
      drawElements(currNodes, currEdges, myPaper) //call draw on the nodes. These are the ones defined in the helper
    }"
  end

end
