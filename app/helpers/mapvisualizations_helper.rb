module MapvisualizationsHelper

  #gets the names of major variables used in javascript functions
  def js_names
    nodes_name = 'currNodes'
    edges_name = 'currEdges'
    paper_name = 'myPaper'
  end

  #helper method to print the nodes and edges as javascript arrays
  def javascript_graph(nodes, edges, nodes_name='currNodes', edges_name='currEdges')
    counts = Hash.new(0)
    edges.each {|e| counts[ [e.a.id,e.b.id].sort.join('-') ] += 1}

    "var "+nodes_name+"={"+
    nodes.map {|n| n.js_k + ":" + n.js(@default_border)} .join(',')+
    ",keys:["+ nodes.map {|n| n.js_k} .join(',') +"]"+
    "};" +
    "var "+edges_name+"={"+
    edges.map {|e| e.js_k + ":" + e.js(nodes_name)} .join(',')+
    ",keys:["+ edges.map {|e| e.js_k} .join(',') +"]"+
    ",counts:{"+counts.map { |k,v| "'"+k+"':"+v.to_s} .join(',') +"}"+
    "};"
  end

  #the code to setup raphael; defined here so separate from the drawing .js file
  def load_raphael
    "var myPaper
      window.onload = function(){
    	myPaper = new Raphael(document.getElementById('canvas_container'), document.getElementById(\"canvas_container\").offsetWidth, document.getElementById(\"canvas_container\").offsetHeight) //graphics context
      drawElements(currNodes, currEdges, myPaper) //call draw on the nodes. These are the ones defined in the helper
    }"
  end

end
