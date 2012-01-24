module MapvisualizationsHelper

  #gets the names of major variables used in javascript functions
  def js_names
    nodes_name = 'currNodes'
    edges_name = 'currEdges'
    paper_name = 'myPaper'
  end

  #helper method to print the nodes and edges as javascript arrays
  def javascript_graph(nodes, edges, nodes_name='currNodes', edges_name='currEdges')
    "var "+nodes_name+"=new Array("+
    nodes.map {|n| n.js(@default_border)} .join(',')+
    ");" +
    "var "+edges_name+"=new Array("+
    edges.map {|n| n.js(nodes.index(n.a), nodes.index(n.b), nodes_name)} .join(',')+
    ");"
  end

  #the code to setup raphael; defined here so separate from the drawing .js file
  def load_raphael
    "var myPaper
      window.onload = function(){
    	myPaper = new Raphael(document.getElementById('canvas_container'), document.getElementById(\"canvas_container\").offsetWidth, document.getElementById(\"canvas_container\").offsetHeight) //graphics context
      drawNodes(currNodes, currEdges, myPaper) //call draw on the nodes. These are the ones defined in the helper
    }"
  end

end
