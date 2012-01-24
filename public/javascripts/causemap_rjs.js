//draw the given nodes and edges on the given paper (a Raphael object)
function drawNodes(nodes, edges, paper)
{
  paper.clear() //clear out old drawings
  //draw nodes
  for(var i=0; i<nodes.length; i++)
  {
    var n = paper.circle(nodes[i].x, nodes[i].y, 10+(nodes[i].weight*6))
    .attr({
      fill: '#54b8dd', stroke: '#bebebe', 'stroke-width': 2
    })
    .data("name",nodes[i].name) //we can put whatever data we need to get to on click here; this can also just be a reference to a hidden div or an ajax call or SOMETHING
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor = 'pointer';})

    var t = paper.text(nodes[i].x, nodes[i].y+25, nodes[i].name)
    .data("name",nodes[i].name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})
  }


  for(var i=0; i<edges.length; i++)
  {
    var a = edges[i].a //for quick access
    var b = edges[i].b

    var e = paper.path("M"+a.x+","+a.y+"L"+b.x+","+b.y+"z").toBack().attr({
      stroke: '#bd55dd',
      'stroke-width': edges[i].weight
    })
    .data("name",edges[i].name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})

  }  
}

function animateNodes(fromNodes, fromEdges, toNodes, toEdges, paper)
{
  paper.clear() //start blank
  easing = "backOut" //either this or linear
  
  for(var i=0; i<fromNodes.length; i++)
  {
    paper.circle(fromNodes[i].x, fromNodes[i].y, 10+(fromNodes[i].weight*6))
    .attr({
      fill: '#54b8dd', stroke: '#bebebe', 'stroke-width': 2
    })
    .data("name",fromNodes[i].name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor = 'pointer';})
    .animate({
      cx: toNodes[i].x,
      cy: toNodes[i].y
    }, 1000, easing)

    paper.text(fromNodes[i].x, fromNodes[i].y+25, fromNodes[i].name)
    .data("name",fromNodes[i].name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})
    .animate({
      x: toNodes[i].x,
      y: toNodes[i].y+25
    }, 1000, easing)
    
  }

  for(var i=0; i<fromEdges.length; i++)
  {
    var fa = fromEdges[i].a //for quick access
    var fb = fromEdges[i].b
    var ta = toEdges[i].a
    var tb = toEdges[i].b

    paper.path("M"+fa.x+","+fa.y+"L"+fb.x+","+fb.y+"z").toBack().attr({
      stroke: '#bd55dd',
      'stroke-width': fromEdges[i].weight
    })
    .data("name",fromEdges[i].name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})
    .animate({
      path: "M"+ta.x+","+ta.y+"L"+tb.x+","+tb.y+"z"
    }, 1000, easing)

  }  
  
}





