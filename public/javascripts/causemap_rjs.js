//draw the given nodes and edges on the given paper (a Raphael object)
//nodes and edges are objects with keys as indices
function drawNodes(nodes, edges, paper)
{
  paper.clear() //clear out old drawings
  //draw nodes
  for(var i=0, len=nodes['keys'].length; i<len; i++)
  {
    node = nodes[nodes['keys'][i]] //easy access

    paper.circle(node.x, node.y, 10+(node.weight*6))
    .attr({
      fill: '#54b8dd', stroke: '#bebebe', 'stroke-width': 2
    })
    .data("name",node.name) //we can put whatever data we need to get to on click here; this can also just be a reference to a hidden div or an ajax call or SOMETHING
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor = 'pointer';})

    paper.text(node.x, node.y+25, node.name)
    .data("name",node.name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})
  }


  for(var i=0, len=edges['keys'].length; i<len; i++)
  {
    edge = edges[edges['keys'][i]]
    a = edge.a //for quick access
    b = edge.b

    paper.path("M"+a.x+","+a.y+"L"+b.x+","+b.y+"z").toBack().attr({
      stroke: '#bd55dd',
      'stroke-width': edge.weight
    })
    .data("name",edge.name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})

  }  
}

function animateNodes(fromNodes, fromEdges, toNodes, toEdges, paper)
{
  paper.clear() //start blank
  easing = "backOut" //either this or linear

  for(var i=0, len=fromNodes['keys'].length; i<len; i++)
  {
    fromNode = fromNodes[fromNodes['keys'][i]] //easy access
    toNode = toNodes[toNodes['keys'][i]] //this should be defined dynamically...

    paper.circle(fromNode.x, fromNode.y, 10+(fromNode.weight*6))
    .attr({
      fill: '#54b8dd', stroke: '#bebebe', 'stroke-width': 2
    })
    .data("name",fromNode.name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor = 'pointer';})
    .animate({
      cx: toNode.x,
      cy: toNode.y
    }, 1000, easing)

    paper.text(fromNode.x, fromNode.y+25, fromNode.name)
    .data("name",fromNode.name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})
    .animate({
      x: toNode.x,
      y: toNode.y+25
    }, 1000, easing)

  }

  for(var i=0, len=fromEdges['keys'].length; i<len; i++)
  {
    fromEdge = fromEdges[fromEdges['keys'][i]]
    fa = fromEdge.a //for quick access
    fb = fromEdge.b
    toEdge = toEdges[toEdges['keys'][i]]
    ta = toEdge.a
    tb = toEdge.b

    paper.path("M"+fa.x+","+fa.y+"L"+fb.x+","+fb.y+"z").toBack().attr({
      stroke: '#bd55dd',
      'stroke-width': fromEdge.weight
    })
    .data("name",fromEdge.name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})
    .animate({
      path: "M"+ta.x+","+ta.y+"L"+tb.x+","+tb.y+"z"
    }, 1000, easing)

  }  
  
}





