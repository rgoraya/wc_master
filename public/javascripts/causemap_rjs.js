/*****
** This file includes methods for drawing the graph on a Raphael.js canvas
*****/

var t_off = 5 //txt offset

//details on drawing/laying out a node
function drawNode(node, paper){
  if(!compact){
    circ = paper.circle(node.x, node.y, 5)//+(node.weight*6))
    .attr({
      fill: '#CA0000', 'stroke-width': 0
    })

    txt = paper.text(node.x, node.y+t_off, node.name)

    icon = paper.set()
    .push(circ,txt)
    .click(function() { clickNode(node)})
    .mouseover(function() {this.node.style.cursor='pointer';})  

    return icon;  
  }
  else{
    circ = paper.circle(node.x, node.y, 2)//+(node.weight*6))
    .attr({fill: '#CA0000', 'stroke-width': 0})

    icon = paper.set()
    .push(circ)
    .click(function() { clickNode(node)})
    .mouseover(function() {this.node.style.cursor='pointer';})  

    return icon;  
  }
}

//details on drawing/laying out an edge (a single line/relationship)
function drawEdge(edge, paper){
    curve = getPath(edge) //get the curve's path

    e = paper.path(curve).toBack() //base to draw
  
    //set attributes based on relationship type (bitcheck with constants)
    if(edge.reltype&INCREASES)
      e.attr({stroke:'#408EB8'})
    else if(edge.reltype&SUPERSET)
      e.attr({stroke:'#BBBBBB'}) //change for superset
    else //if decreases
      e.attr({stroke:'#BA717F'})
    // if(edge.reltype&HIGHLIGHTED)
    //   e.glow({width:3,fill:false,color:'#FFFF00'}) //would have to animate this as well it seems...

    if(!compact)
      e.attr({'stroke-width':2})
    else
      e.attr({'stroke-width':1})
    
    icon = paper.set() //for storing pieces of the line as needed
    icon.push(e)
    .click(function() { clickEdge(edge, curve)})
    .mouseover(function() {this.node.style.cursor='pointer';})

    return icon;
}


//returns an a curved path for an edge, curving based on which number edge this is
//so for example: the 0th edge could be straight, 1st could curve up, 2nd could curve down, etc
function getPath(edge)
{
  a = edge.a //for quick access
  b = edge.b

  //-----------------Calculate the third point of Equilateral Triangle on the coordinate as the control point------------------
  pivotPoint = (b.x > a.x) ? a : b
  dx = b.x - a.x
  dy = b.y - a.y 
  lengthAB = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2))
  angleAB = Math.atan(dy/dx)

  if(edge.n == 0){ //Curve "0" -- straight line if we want it
    return "M"+a.x+","+a.y+"L"+b.x+","+b.y+"z"
  }

  if(Math.abs(edge.n) == 1){ //Curve "1"
    if(edge.n > 0){
      ctrlx = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.cos(angleAB + 30 * Math.PI/180) + pivotPoint.x
      ctrly = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.sin(angleAB + 30 * Math.PI/180) + pivotPoint.y
    }
    else{
      //change to flip the curve
      ctrlx = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.cos(angleAB + 30 * Math.PI/180) + pivotPoint.x
      ctrly = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.sin(angleAB + 30 * Math.PI/180) + pivotPoint.y
    }
    return "M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y
  }

  if(Math.abs(edge.n) == 2){ //Curve "2"
    if(edge.n > 0){
      ctrlx = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.cos(angleAB + 45 * Math.PI/180) + pivotPoint.x
      ctrly = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.sin(angleAB + 45 * Math.PI/180) + pivotPoint.y 
    else{
      //change to flip the curve
      ctrlx = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.cos(angleAB + 30 * Math.PI/180) + pivotPoint.x
      ctrly = lengthAB / (2 * Math.cos(30 * Math.PI/180)) * Math.sin(angleAB + 30 * Math.PI/180) + pivotPoint.y
    }
    return "M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y
  }

  if(Math.abs(edge.n) == 3) {//Curve "3"
    //curve 3 should probably be a straight line? Like a function of whether there are even or odd curves? Something to think about.
    //like have the edges bend out based on the magnitude of n, where even and odd n are flips of each other, and if odd total the last is straight. Would be clean and somewhat slick.
    if(edge.n > 0){
      ctrlx = lengthAB / (2 * Math.cos(55 * Math.PI/180)) * Math.cos(angleAB + 55 * Math.PI/180) + pivotPoint.x
      ctrly = lengthAB / (2 * Math.cos(55 * Math.PI/180)) * Math.sin(angleAB + 55 * Math.PI/180) + pivotPoint.y 
    }
    else{
      //change to flip the curve
      ctrlx = lengthAB / (2 * Math.cos(55 * Math.PI/180)) * Math.cos(angleAB + 55 * Math.PI/180) + pivotPoint.x
      ctrly = lengthAB / (2 * Math.cos(55 * Math.PI/180)) * Math.sin(angleAB + 55 * Math.PI/180) + pivotPoint.y       
    }
    return "M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y
  }
  
  return "" //in case we didn't get anything?
}


//Interaction functions, for when we click on things. Variables passed are things we're going to use
function clickNode(node){
  alert(node.name);
}

function clickEdge(edge, curve){
  alert(edge.name+"\n"+curve);
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
      icon.animate({'opacity':0, 'fill-opacity':0}, 1500, 'linear', function(){this.remove()}) //disappear
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
    fromEdge = fromEdges[fromEdges['keys'][i]] //old edge
    toEdge = toEdges[fromEdges['keys'][i]] //see if we have an edge with the same key

    icon = drawEdge(fromEdge, paper)

    if(typeof toEdge === 'undefined'){ //if no toEdge
      icon.animate({'opacity':0, 'fill-opacity':0}, 1500, 'linear', function(){this.remove()}) //disappear
    }
    else{
	    icon.animate({'path':getPath(toEdge)},1000,easing); //pass the new path
    }
  }  
  
  for(var i=0, len=toEdges['keys'].length; i<len; i++)
  {
    toEdge = toEdges[toEdges['keys'][i]]
    fromEdge = fromEdges[toEdges['keys'][i]] //see if there used to be an edge with the same key

    if(typeof fromEdge === 'undefined'){ //if no fromEdge
      drawEdge(toEdge, paper)
      .attr({'opacity':0, 'fill-opacity':0})
      .animate({'opacity':1, 'fill-opacity':1}, 1000, 'linear')
    }
  }  
} //animateNodes





