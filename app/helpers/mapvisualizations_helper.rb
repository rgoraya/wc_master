module MapvisualizationsHelper

  #helper method to print the nodes and edges as javascript arrays
  def javascript_graph(nodes, edges)
    "var nodes=new Array("+
    nodes.map {|n| n.js} .join(',')+
    ");" +
    "var edges=new Array("+
    edges.map {|n| n.js(nodes.index(n.a), nodes.index(n.b))} .join(',')+
    ");"
  end
end
