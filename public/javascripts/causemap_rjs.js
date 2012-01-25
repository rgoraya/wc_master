/*****
** This file includes methods for drawing the graph on a Raphael.js canvas
*****/

//details on drawing/laying out a node
function drawNode(node, paper){
  circ = paper.circle(node.x, node.y, 10+(node.weight*6))
  .attr({
    fill: '#54b8dd', stroke: '#bebebe', 'stroke-width': 2
  })
  .data("name",node.name)
  .click(function() { alert("You clicked on "+this.data("name"))})
  .mouseover(function() {this.node.style.cursor = 'pointer';})

  txt = paper.text(node.x, node.y+25, node.name)
  .data("name",node.name) //if needed
  .click(function() { alert("You clicked on "+this.data("name"))})
  .mouseover(function() {this.node.style.cursor='pointer';})  
  
  //put them into set and return set!!
  icon = paper.set();
  icon.push(circ, txt);
  return icon;  
}

//details on drawing/layint out an edge
function drawEdge(edge, paper){
  a = edge.a //for quick access
  b = edge.b

  e = paper.path("M"+a.x+","+a.y+"L"+b.x+","+b.y+"z").toBack().attr({
    stroke: '#bd55dd',
    'stroke-width': edge.weight
  })
  .data("name",edge.name) //if needed
  .click(function() { alert("You clicked on "+this.data("name"))})
  .mouseover(function() {this.node.style.cursor='pointer';})

  return e; //can put this in a set if needed
}

//a basic draw function
//draw the given nodes and edges on the given paper (a Raphael object)
//nodes and edges are objects of objects; includes 'keys' as an array of the keys for iterating
function drawElements(nodes, edges, paper)
{
  paper.clear() //clear out old drawings
  //draw nodes
  for(var i=0, len=nodes['keys'].length; i<len; i++){
    node = nodes[nodes['keys'][i]] //easy access
    drawNode(node, paper)
  }

  for(var i=0, len=edges['keys'].length; i<len; i++){
    edge = edges[edges['keys'][i]]
    drawEdge(edge, paper)
  }
}


//animate change between old nodes/edges and new nodes/edges
function animateElements(fromNodes, fromEdges, toNodes, toEdges, paper)
{
  paper.clear() //start blank
  easing = "backOut" //either this or linear look nice

  //move the old nodes into the new
  for(var i=0, len=fromNodes['keys'].length; i<len; i++)
  {
    fromNode = fromNodes[fromNodes['keys'][i]] //easy access
    toNode = toNodes[fromNode['id']] //corresponding toNode (one that has id as key; could also just check if has the same key)

    icon = drawNode(fromNode, paper)

    if(typeof toNode === 'undefined'){ //if no toNode
      icon.animate({'opacity':0, 'fill-opacity':0}, 1500, 'linear') //disappear
    }
    else{
      icon.animate({ cx: toNode.x, cy: toNode.y, x: toNode.x, y: toNode.y+25 }, 1000, easing)
    }
  }
  
  //also check if anyone needs to appear, and make those as well
  for(var i=0, len=toNodes['keys'].length; i<len; i++)
  {
    toNode = toNodes[toNodes['keys'][i]] //easy access
    fromNode = fromNodes[toNode['id']] //corresponding fromNode (one that has id as key; could also just check if has the same key)

    if(typeof fromNode === 'undefined'){ //if no fromNode
      drawNode(toNode, paper)    
      .attr({'opacity':0, 'fill-opacity':0})
      .animate({'opacity':1, 'fill-opacity':1}, 1000, 'linear')
    }
  }

  //move old edges into the new
  for(var i=0, len=fromEdges['keys'].length; i<len; i++)
  {
    fromEdge = fromEdges[fromEdges['keys'][i]]
    toEdge = toEdges[toEdges['keys'][i]]

    icon = drawEdge(fromEdge, paper)

    if(typeof toEdge === 'undefined'){ //if no toEdge
      icon.animate({'opacity':0, 'fill-opacity':0}, 1500, 'linear') //disappear
    }
    else{
      icon.animate({ path: "M"+toEdge.a.x+","+toEdge.a.y+"L"+toEdge.b.x+","+toEdge.b.y+"z" }, 1000, easing)
    }
  }  
  
  for(var i=0, len=toEdges['keys'].length; i<len; i++)
  {
    fromEdge = fromEdges[fromEdges['keys'][i]]
    toEdge = toEdges[toEdges['keys'][i]]

    if(typeof fromEdge === 'undefined'){ //if no fromEdge
      drawEdge(toEdge, paper)
      .attr({'opacity':0, 'fill-opacity':0})
      .animate({'opacity':1, 'fill-opacity':1}, 1000, 'linear')
    }
  }  
} //animateNodes





