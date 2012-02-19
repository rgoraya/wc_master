module MapvisualizationsHelper
  include	ActionView::Helpers::JavaScriptHelper #for javascript escaping

  DECREASES = 0
  INCREASES = 1 #constants for relationship type
  SUPERSET = 4
  EXPANDABLE = 8
  HIGHLIGHTED = 16

  #gets the names of major variables used in javascript functions
  def js_names
    nodes_name = 'currNodes'
    edges_name = 'currEdges'
    paper_name = 'myPaper'
  end

  # returns a string for an element in javascript object representing the node (includes key)
  def js_node(node, offset=0)
    js_node_key(node) + ":"+
    "{id:"+node.id.to_s+","+
    "name:'"+escape_javascript(node.name)+"',"+
    "x:"+(node.location[0]+offset).round.to_s+",y:"+(node.location[1]+offset).round.to_s+","+
    "url:'"+escape_javascript(node.url)+"'}"
    #can add more fields as needed
  end

  # returns a string representing just the key of the node
  def js_node_key(node)
    node.id.to_s
  end

  # returns a string for a javascript object representing the edge
  def js_edge(edge, nodeset='nodes', count=0)
    js_edge_key(edge) + ":"+
    "{id:"+edge.id.to_s+","+
    "name:'"+escape_javascript(edge.name)+"',"+
    "a:"+nodeset+"["+js_node_key(edge.a)+"],b:"+nodeset+"["+js_node_key(edge.b)+"]"+","+
    "reltype:"+edge.rel_type.to_s+","+
    "n:"+count.to_s+"}"
  end

  # returns a string representing just the key of the edge
  # a unique key for the edge (A-B) => (AiehB) / (AdB) / (AsB), etc
  def js_edge_key(edge)
      conn = edge.rel_type & INCREASES != 0 ? 'i' : (edge.rel_type & SUPERSET == 0 ? 'd' : 's')
      conn += 'e'*[(edge.rel_type&EXPANDABLE),1].min + 'h'*[(edge.rel_type&HIGHLIGHTED),1].min
      "'"+js_node_key(edge.a)+conn+js_node_key(edge.b)+"'"
  end


  #helper method to print the nodes and edges as javascript arrays, now with empty-set handling!
  def javascript_graph(nodes, edges, adjacency, nodes_name='currNodes', edges_name='currEdges')
    out = ""
    if nodes.length > 0
      out += "var "+nodes_name+"={"+
        nodes.map {|k,n| js_node(n,@default_border)} .join(',')+
        ",keys:["+ nodes.map {|k,n| js_node_key(n)} .join(',') +"]"+
        "};"
    else
      out += "var "+nodes_name+"={keys:[]};"
    end
      
    if edges.length > 0
      multi_edge = Hash[edges.group_by {|e| [e.a.id,e.b.id].sort}.map {|k,v| [k,v.count]}] #number edges per nodepair

      counters = Hash.new(0)
      out += "var "+edges_name+"={"+
        edges.map {|e| es = [e.a.id,e.b.id].sort; js_edge(e,nodes_name, 
          ((counters[es] += 1) == multi_edge[es] and multi_edge[es]%2==1) ? 0 : counters[es])
          #multi_edge[[e.a.id,e.b.id].sort] == 1 ? 0 : (counters[ [e.a.id,e.b.id].sort ] += 1)*(e.a.id < e.b.id ? 1 : -1))
          }.join(',')+
        ",keys:["+ edges.map {|e| js_edge_key(e)} .join(',') +"]"+
        "};"
    else
      out += "var "+edges_name+"={keys:[]};"
    end
    #puts out
    return out      
  end

  #the code to setup raphael; defined here so separate from the drawing .js file (and can be dynamically generated)
  #also includes top-level processing used by the drawing code
  def load_raphael(compact=false)
    "var INCREASES = #{INCREASES} //type constants
    var SUPERSET = #{SUPERSET}
    var EXPANDABLE = #{EXPANDABLE}
    var HIGHLIGHTED = #{HIGHLIGHTED}

    var compact = #{compact.to_s} //for compact drawing; can also pass as a variable if we want
    
    var myPaper
      window.onload = function(){
    	myPaper = new Raphael(document.getElementById('canvas_container'), document.getElementById(\"canvas_container\").offsetWidth, document.getElementById(\"canvas_container\").offsetHeight) //graphics context
      drawElements(currNodes, currEdges, myPaper) //call draw on the nodes. These are the ones defined in the helper
    }"
  end

end
