/*****
** This file includes methods for drawing the graph on a Raphael.js canvas
*****/

var t_off = 5

//details on drawing/laying out a node
function drawNode(node, paper){
  circ = paper.circle(node.x, node.y, 5)//+(node.weight*6))
  .attr({
    fill: '#CA0000', stroke: '#CA0000i', 'stroke-width': 2
  })

  txt = paper.text(node.x, node.y+t_off, node.name)
  
  //put them into set and return set!!
  icon = paper.set()
  icon.push(circ, txt)
  .data("name",node.name) //if needed
  .click(function() { alert("You clicked on "+this.data("name"))})
  .mouseover(function() {this.node.style.cursor='pointer';})  
  
  return icon;  
}

//details on drawing/layint out an edge
function drawEdge(edge, paper){    
  a = edge.a //for quick access
  b = edge.b
  
  // random number of edge/curve between two nodes 
  numofedges = 1 // Math.floor(Math.random()*11) % 3 + 1 //problem is that this can't be randomly determined on each draw, needs to be based on a static edge value!

  curvePaths = getCurves(edge, numofedges) //get the curve paths

  e = paper.path(curvePaths[0]).toBack().attr({
    stroke: '#408EB8',
    'stroke-width': edge.nc
  })
  
  // Curve 2
  if (numofedges > 1) {
    paper.path(curvePaths[1]).toBack().attr({
    stroke: '#40A500',
    'stroke-width': edge.nc
  })
  } 

  // Curve 3
  if (numofedges > 2) {
    paper.path(curvePaths[2]).toBack().attr({
    stroke: '#BBBBBB',
    'stroke-width': edge.nc
  })
  } 


  // e2 = paper.path(curvePaths[2]).toBack().attr({
  //   stroke: '#408EB8',
  //   'stroke-width': edge.nc
  // })

  e.data("name",edge.name) //if needed
  .click(function() { alert("You clicked on "+this.data("name")+"\n"+"M"+a.x+","+a.y+"\n Q " + ctrlx + ","+ctrly+" \n"+b.x+","+b.y)})

  icon = paper.set()
  icon.push(e) //.push(e,e2,e3)  
  .mouseover(function() {this.node.style.cursor='pointer';})
  return icon;
}

//returns an array of curve paths
function getCurves(edge, numofedges)
{
  a = edge.a //for quick access
  b = edge.b
    
  //-----------------Calculate the third point of Equilateral Triangle on the coordinate as the control point------------------
  pivotPoint = (b.x > a.x) ? a : b

  dx = b.x - a.x
  dy = b.y - a.y 

  lengthAB = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2))
  angleAB = Math.atan(dy/dx)

  // Curve 1
  ctrlx = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.cos(angleAB + 30 * Math.PI/180) + pivotPoint.x
  ctrly = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.sin(angleAB + 30 * Math.PI/180) + pivotPoint.y
  
  curvePaths = ["M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y]

  // Curve 2
  if (numofedges > 1) {
    ctrlx = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.cos(angleAB + 45 * Math.PI/180) + pivotPoint.x
    ctrly = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.sin(angleAB + 45 * Math.PI/180) + pivotPoint.y 
    curvePaths.push("M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y)
  }

  // Curve 3
  if (numofedges > 2) {
    ctrlx = lengthAB / (2 * Math.cos(55 * Math.PI/180)) * Math.cos(angleAB + 55 * Math.PI/180) + pivotPoint.x
    ctrly = lengthAB / (2 * Math.cos(55 * Math.PI/180)) * Math.sin(angleAB + 55 * Math.PI/180) + pivotPoint.y 
    curvePaths.push("M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y)
  } 

  return curvePaths
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
      icon.animate({ cx: toNode.x, cy: toNode.y, x: toNode.x, y: toNode.y+t_off }, 1000, easing)
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
      toCurves = getCurves(toEdge,1) //spec how many edges we need? if >1 will need to loop
	    icon[0].animate({'path':toCurves[0]},1000,easing); //do the first edge
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





