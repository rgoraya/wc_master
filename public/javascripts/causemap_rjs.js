/*****
** This file includes methods for drawing the graph on a Raphael.js canvas
** NOTE that "paper" is not a global variable so we can access it in drags
*****/

var T_OFF = 9 //txt offset

var ARROW_LENGTH = 15 // arrowhead length
var ARROW_HEIGHT = 6 // arrowhead height
var REC1_EDGE = 9 // big rectangle size (supersets)
var REC2_EDGE = 6.5 // small rectangle size (supersets)
var NUM_OF_DOTS = 3		// number of dots each side of EXPAND symbol

var EDGE_COLORS = {'increases':'#C06B82','decreases':'#008FBD','superset':'#BBBBBB'}
var DESEL_OP = 0.4

//hashes to store the things we've drawn, so we can manipulate them. Keyed by id
var nodeIcons = {} 
var edgeIcons = {}

var now_detailing = 0 //status variable for what we're currently displaying on hover
var now_dragging = null //the thing we're dragging
var drag_origin = {cx:0, cy:0, x:0, y:0, id:0} //the origin/info for the node before we started dragging
var dragged_edges = [] //the edges connected to the thing we're dragging


//details on drawing/laying out a node
function drawNode(node, paper){
	if(!compact){

		var txt = paper.text(node.x, node.y+T_OFF, node.name)
		var circ = paper.circle(node.x, node.y, 5)//+(node.weight*6))
		.attr({
			fill: '#FFD673', 'stroke': '#434343', 'stroke-width': 1,
		})

		if(hasSelection){
			if(!node.h) //if not highlighted
				icon.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
		}

		var icon = paper.set()
		.push(circ,txt)
		.click(function(e) {clickNode(node, e)})
		//.click(function() { get_issue(node, show_modal)})
		.mouseover(function() {this.node.style.cursor='pointer';hoverNode(node)})
		// .mouseout(function() {unhoverNode(node)})
		.mousedown(function (e) {
			// console.log("mousedown")
			if(e.shiftKey){
				now_dragging = {icon:icon, node:node};
				// console.log("now_dragging:", icon)
				// console.log(node.name)
			}
		})
		.drag(dragmove, dragstart, dragend) //enable dragging!


		$(circ.node).qtip({content:{text:node.name}}); //if we want a tooltip

		return icon;  
	}
	else{
		var circ = paper.circle(node.x, node.y, 2)//+(node.weight*6))
		.attr({fill: '#FFD673', 'stroke': '#434343', 'stroke-width': .5})

		var icon = paper.set()
		.push(circ)
		.click(function() { get_issue(node, show_modal)})
		.mouseover(function() {this.node.style.cursor='pointer';})

		$(circ.node).qtip({content:{text:node.name}}); //if we want a tooltip

		return icon;  
	}
}

//details on drawing/laying out an edge (a single line/relationship)
function drawEdge(edge, paper){
	if(!compact){	
		var a = edge.a;
		var b = edge.b;

		var curve = getPath(edge) //get the curve's path		
		var e = paper.path(curve).attr({'stroke-width':2})
		
		//set attributes based on relationship type (bitcheck with constants)
		if(edge.reltype&INCREASES)
			e.attr({stroke:EDGE_COLORS['increases']})
		else if(edge.reltype&SUPERSET)
			e.attr({stroke:EDGE_COLORS['superset']})
		else //if decreases
			e.attr({stroke:EDGE_COLORS['decreases']})
		
		var arrow = drawArrow(edge, curve, paper)		
		var dots = drawDots(edge, curve, paper)

		if(hasSelection){
			if((edge.reltype&HIGHLIGHTED)==0){ //if not highlighted
				e.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
				arrow[0].attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
				dots.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
		}}

		var icon = paper.set() //for storing pieces of the line as needed
		.push(e, arrow[0], arrow[1], dots)
		//.click(function() { clickEdge(edge) })
		.mouseover(function() { hoverEdge(edge) })
		//.mouseout(function() { unhoverEdge(edge) })

		$([e.node,arrow[0].node,arrow[1].node]).qtip({
			content:{text:edge.name},
			position:{target: 'mouse', adjust:{y:5}}
		});

		return icon;
	}
	else{	
		var curve = getPath(edge) //get the curve's path
		var e = paper.path(curve).attr({'stroke-width':1}) //base to draw

		//set attributes based on relationship type (bitcheck with constants)
		if(edge.reltype&INCREASES)
			e.attr({stroke:EDGE_COLORS['increases']}) //BA717F
		else if(edge.reltype&SUPERSET)
			e.attr({stroke:EDGE_COLORS['superset']}) //BBBBBB change for superset
		else //if decreases
			e.attr({stroke:EDGE_COLORS['decreases']}) //408EB8, 54B9D9

		if(hasSelection){
			if((edge.reltype&HIGHLIGHTED)==0){ //if not highlighted
				e.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
		}}

		var icon = paper.set() //for storing pieces of the line as needed
		.push(e)
		.click(function() { clickEdge(edge) })
		.mouseover(function() {this.node.style.cursor='pointer';})

		$(e.node).qtip({
			content:{text:edge.name},
			position:{target: 'mouse', adjust:{y:5}}
		});

		return icon;
	}
}

//returns an a curved path for an edge, curving based on which number edge this is
//so for example: the 0th edge could be straight, 1st could curve up, 2nd could curve down, etc
function getPath(edge)
{
	var a = edge.a //for quick access
	var b = edge.b

	if(edge.n == 0){ //if the odd curve, then just draw a straight line
		return "M "+a.x+","+a.y+" L "+b.x+","+b.y
	}
	else{ //otherwise, calculate curves. Control point is some distance along the perpendicular bisector
		var center = [(a.x+b.x)/2, (a.y+b.y)/2]
		var normal = [center[1]-a.y, a.x-center[0]]
		var scale = .3*Math.ceil(edge.n/2) //scale bend based on how many edges there are
		var control = [center[0]+scale*normal[0], center[1]+scale*normal[1]]
		
		// console.log("control",control)
		return "M"+a.x+","+a.y+" Q "+control[0]+","+control[1]+" "+b.x+","+b.y
	}

	return "" //in case we didn't get anything?
}

function getPathCenter(path, offset, flip)
{
	var offset = typeof offset !== 'undefined' ? offset : 0;
	var flip = typeof offset !== 'undefined' ? flip : false;

	var pathLength = Raphael.getTotalLength(path);

	//catching an error if our path isn't long enough to find a point with the offset
	try {var midPoint = Raphael.getPointAtLength(path,pathLength/2 + offset);}
	catch(err) {var midPoint = Raphael.getPointAtLength(path,pathLength/2)}
	return midPoint;
}

//gets the path of an arrow drawn at a particular point
//point is a Raphael.getPointAtLength object {x,y,alpha}
function getArrowPath(point, reltype)
{
	if (reltype&INCREASES)
		return "M" + point.x + " " + point.y + " L" + (point.x - ARROW_LENGTH) + " " + (point.y - ARROW_HEIGHT) + " L" + (point.x - ARROW_LENGTH) + " " + (point.y + ARROW_HEIGHT) + " L" + point.x + " " + point.y;
	else if(reltype&SUPERSET)
		return "M" + point.x + " " + point.y + " l 0 " + (0 - REC2_EDGE/2) + " l "  + REC2_EDGE + " 0 l 0 " + REC2_EDGE  + " l " + (0 - REC2_EDGE)+" 0 l 0 "+(0 - (REC1_EDGE/2+REC2_EDGE/2))+" l "+(0 - REC1_EDGE)+" 0 l 0 "+REC1_EDGE+" l "+REC1_EDGE+" 0 z";
	else
		return "M" + point.x + " " + point.y + " L" + (point.x - ARROW_LENGTH) + " " + (point.y - ARROW_HEIGHT) + " L" + (point.x - ARROW_LENGTH) + " " + (point.y + ARROW_HEIGHT) + " L" + point.x + " " + point.y;
	
}

//gets the path to draw the symbol inside an arrow
//should this be a text function instead?
function getArrowSymbolPath(point, reltype)
{
	symbolSize = 2;
	x_off = -7
	y_off = 1

	if(reltype&INCREASES){
		return "M " + (point.x+x_off) + " " + (point.y+y_off) + " l 0 " + (0 - symbolSize) + " l " + (0 - symbolSize) + " 0 l 0 " + (0 - symbolSize) + " l " + (0 - symbolSize) + " 0 l 0 " + symbolSize + " l " + (0 - symbolSize) + " 0 l 0 " + symbolSize + " l " + symbolSize + " 0 l 0 " + symbolSize + " l " + symbolSize + " 0 l 0 " + (0 - symbolSize);
	}
	else if(reltype&SUPERSET){
		return "M " + (point.x+x_off) + " " + (point.y+y_off); //  should delete this object or make another icon !
	}
	else{  //if decreases 
		return "M " + (point.x+x_off) + " " + (point.y+y_off) + " l 0 " + (0 - symbolSize) + " l " + (0 - symbolSize*3) + " 0 l 0 " + symbolSize;
	}
	
	return "" //if problem
}

function drawArrow(edge, curve, paper)
{
	var a = edge.a
	var b = edge.b
	
	if (edge.reltype&SUPERSET)
		var midPoint = getPathCenter(curve);
	else
		var midPoint = getPathCenter(curve, ARROW_LENGTH/2); //midpoint offset by arrow-length

	if(a.x <= b.x && b.y <= a.y){ //sometimes we need to flip the alpha, seems to be covered by this
		if(!(b.y == a.y && midPoint.alpha > 360)){ //handle special case, if b.y == a.y, seems to work 
			//console.log("flipped",edge.name)
			midPoint.alpha = midPoint.alpha+180 % 360 //flip 180 degrees so pointed in right direction
			//console.log("alpha after flip",midPoint.alpha)
	}}

	var arrowPath = getArrowPath(midPoint, edge.reltype)
	var arrow = paper.path(arrowPath) //draw the arrowhead
		.attr({stroke:'#FFFFFF', 'stroke-width': 1.3})
		.rotate(midPoint.alpha, midPoint.x, midPoint.y)
	var arrowSymbolPath = getArrowSymbolPath(midPoint, edge.reltype)
	var arrowSymbol = paper.path(arrowSymbolPath, edge.reltype) //draw the symbol on the arrow
		.attr({fill:'#FFFFFF', stroke:'none'})
		.rotate(midPoint.alpha, midPoint.x, midPoint.y)

	//set attributes based on relationship type (bitcheck with constants)
	if(edge.reltype&INCREASES){
		arrow.attr({fill:EDGE_COLORS['increases']})
	}
	else if(edge.reltype&SUPERSET){
		arrow.attr({fill:EDGE_COLORS['superset']})
	}
	else{ //if decreases
		arrow.attr({fill:EDGE_COLORS['decreases']});	
	}

	var icon = paper.set();
	icon.push(arrow,arrowSymbol)
	return icon
}


// draws dots if the curve is expandable, and returns the set of dots. Otherwise, just returns an empty set
function drawDots(edge, curve, paper)
{
	var dots = paper.set();
	if(edge.expandable){ //if we expand, fill in the dots
		var expand_cr = [];
		var expand_cl = [];
		var pathLength = Raphael.getTotalLength(curve);
		
		var offset_r = ARROW_LENGTH/2
		var offset_l = ARROW_LENGTH/2
		if(edge.reltype&SUPERSET){
			offset_r = REC2_EDGE;
			offset_l = REC1_EDGE;
		}

		for(i=0; i<NUM_OF_DOTS; i++) {
			//expand_cr[i] = Raphael.getPointAtLength(curve,pathLength/2 + offset_r + EXPAND_DIST_TO_ICON + EXPAND_DIST_BETWEEN*i);
			expand_cr[i] = Raphael.getPointAtLength(curve,pathLength/2 + offset_r + 3 + 5*i);
			expand_cl[i] = Raphael.getPointAtLength(curve,pathLength/2 - offset_l - 3 - 5*i);
			dots.push(paper.circle(expand_cr[i].x, expand_cr[i].y, 2.5),
								paper.circle(expand_cl[i].x, expand_cl[i].y, 2.5));
		}
		dots.attr({stroke:"#FFFFFF",'stroke-width':'2'})

		if(edge.reltype&INCREASES) //set color in here to clean up animation method
			dots.attr({fill:EDGE_COLORS['increases']})
		else if(edge.reltype&SUPERSET)
			dots.attr({fill:EDGE_COLORS['superset']})
		else //if decreases
			dots.attr({fill:EDGE_COLORS['decreases']})
	}

	return dots
}

//a basic draw function
//draw the given nodes and edges on the given paper (a Raphael object)
//nodes and edges are objects of objects; includes 'keys' as an array of the keys for iterating
function drawElements(nodes, edges, paper)
{
	paper.clear() //clear out old drawings

	//draw edges (below the nodes)
	for(var i=0, len=edges['keys'].length; i<len; i++){
		var edge = edges[edges['keys'][i]]
		edgeIcons[edge.id] = drawEdge(edge, paper)
	}

	//draw nodes
	for(var i=0, len=nodes['keys'].length; i<len; i++){
		var node = nodes[nodes['keys'][i]] //easy access
		nodeIcons[node.id] = drawNode(node, paper)
	}
}

var MOVE_TIME = 400
var DISAPPEAR_TIME = 250
var APPEAR_TIME = 250
var SEP_TIME = 100

//animate change between old nodes/edges and new nodes/edges
function animateElements(fromNodes, fromEdges, toNodes, toEdges, paper)
{
	paper.clear() //start blank
	easing = "linear" //either this or backOut look nice IMO

	//standard animations
	var disappear = Raphael.animation({'opacity':0, 'fill-opacity':0}, DISAPPEAR_TIME, 'linear', function(){this.remove()})
	var tempVanish = Raphael.animation({'opacity':0, 'fill-opacity':0}, 1, 'linear', function(){this.remove()})
		.delay(DISAPPEAR_TIME+SEP_TIME) //for temporary disappearing before move
	var appear = Raphael.animation({'opacity':1, 'fill-opacity':1}, APPEAR_TIME, 'linear')
		.delay(DISAPPEAR_TIME+SEP_TIME+MOVE_TIME+SEP_TIME)

	var toAnimate = [] //the animations we want to run

	//move old edges into the new
	for(var i=0, len=fromEdges['keys'].length; i<len; i++)
	{
		var fromEdge = fromEdges[fromEdges['keys'][i]] //old edge
		var toEdge = toEdges[fromEdges['keys'][i]] //see if we have an edge with the same key

		var icon = drawEdge(fromEdge, paper)

		if(typeof toEdge === 'undefined'){ //if no toEdge
			toAnimate.push({el:icon, anim:disappear})
		}
		else{
			if(!compact){ //not compact so we need to move arrows as well
				var curve = getPath(toEdge) //get the new curve's path

				var arrow = drawArrow(toEdge,curve,paper) //just go ahead and redraw the arrow and dots
				.attr({'opacity':0, 'fill-opacity':0})
				icon.push(arrow[0],arrow[1])
				var dots = drawDots(toEdge,curve,paper)
				.attr({'opacity':0, 'fill-opacity':0})
				icon.push(dots)
				
				var curveMovement = Raphael.animation({'path':curve},MOVE_TIME,easing,
					(function(arrow, dots) { return function() {
						arrow.attr({'opacity':1, 'fill-opacity':1})
						dots.attr({'opacity':1, 'fill-opacity':1})
					}; })(arrow, dots)
				).delay(DISAPPEAR_TIME+SEP_TIME)
				toAnimate.push({el:icon[0], anim:curveMovement})

				toAnimate.push({el:icon[1], anim:tempVanish})
				toAnimate.push({el:icon[2], anim:tempVanish})
				toAnimate.push({el:icon[3], anim:tempVanish})
			}
			else{
				var curveMovement = Raphael.animation({'path':getPath(toEdge)},MOVE_TIME,easing)
					.delay(DISAPPEAR_TIME+SEP_TIME)
				toAnimate.push({el:icon, anim:curveMovement})
			}
		}
	}

	for(var i=0, len=toEdges['keys'].length; i<len; i++)
	{
		var toEdge = toEdges[toEdges['keys'][i]]
		var fromEdge = fromEdges[toEdges['keys'][i]] //see if there used to be an edge with the same key

		if(typeof fromEdge === 'undefined'){ //if no fromEdge
			var icon = drawEdge(toEdge, paper)
			.attr({'opacity':0, 'fill-opacity':0})
			toAnimate.push({el:icon, anim:appear})
		}
	}  

	//move the old nodes into the new
	for(var i=0, len=fromNodes['keys'].length; i<len; i++)
	{
		var fromNode = fromNodes[fromNodes['keys'][i]] //easy access
		var toNode = toNodes[fromNode['id']] //corresponding toNode (one that has id as key; could also just check if has the same key)

		var icon = drawNode(fromNode, paper)

		if(typeof toNode === 'undefined'){ //if no toNode
			toAnimate.push({el:icon, anim:disappear})
		}
		else{
			fromNode.x = toNode.x; fromNode.y = toNode.y; //change the stored location for future querying (interaction)
			var move = Raphael.animation({ cx: toNode.x, cy: toNode.y, x: toNode.x, y: toNode.y+T_OFF }, MOVE_TIME, easing)
				.delay(DISAPPEAR_TIME+SEP_TIME)
			toAnimate.push({el:icon, anim:move})
		}
	}

	//also check if anyone needs to appear, and make those as well
	for(var i=0, len=toNodes['keys'].length; i<len; i++)
	{
		var toNode = toNodes[toNodes['keys'][i]] //easy access
		var fromNode = fromNodes[toNode['id']] //corresponding fromNode (one that has id as key; could just check if has the same key)

		if(typeof fromNode === 'undefined'){ //if no fromNode
			var icon = drawNode(toNode, paper)    
			.attr({'opacity':0, 'fill-opacity':0})
			toAnimate.push({el:icon, anim:appear})
		}
	}
	
	//now... animate everyone!!
	var el0 = toAnimate[0].el
	var anim0 = toAnimate[0].anim
	el0.animate(anim0)
	for(var i=1, len=toAnimate.length; i<len; i++)
	{
		toAnimate[i].el.animateWith(el0, anim0, toAnimate[i].anim)
	}
} //animateNodes

//methods to control dragging
var dragstart = function (x,y,event) 
{
	if(event.shiftKey && now_dragging) {
		drag_origin.cx = now_dragging.icon[0].attr('cx'); //store the original locations
	  drag_origin.cy = now_dragging.icon[0].attr('cy');
		drag_origin.x = now_dragging.icon[1].attr('x');
		drag_origin.y = now_dragging.icon[1].attr('y');

		for(var i=0, len=currEdges['keys'].length; i<len; i++)
		{
			var edge = currEdges[currEdges['keys'][i]]
			if(edge.a == now_dragging.node || edge.b == now_dragging.node){
				dragged_edges.push(edge) //SHOULD THIS BE STORING THE ICONS RATHER THAN THE EDGES?? NO, SINCE WE'LL WANT TO ADJUST
				edgeIcons[edge.id][1].attr({'opacity':0, 'fill-opacity':0}) //vanish the symbol, since we're not moving it
				edgeIcons[edge.id][2].attr({'opacity':0, 'fill-opacity':0})
				edgeIcons[edge.id][3].attr({'opacity':0, 'fill-opacity':0})
			}
		}
	}
};
var dragmove = function (dx,dy,x,y,event) 
{
	if(event.shiftKey && now_dragging) {
		now_dragging.node.x = drag_origin.cx+dx
		now_dragging.node.y = drag_origin.cy+dy //move the node itself; this will move the appropriate edges
		now_dragging.icon.attr({cx: drag_origin.cx+dx, cy: drag_origin.cy+dy, x: drag_origin.x+dx, y: drag_origin.y+dy});
		
		for(var i=0, len=dragged_edges.length; i<len; i++)
		{
			var curve = getPath(dragged_edges[i]) //get new curve
			edgeIcons[dragged_edges[i].id].attr({'path':curve})
		}
	}
};
var dragend = function (x,y,event) 
{	
	for(var i=0, len=dragged_edges.length; i<len; i++) //redraw the icons on the edges
	{
		var curve = getPath(dragged_edges[i]) //get new curve
		var arrow = drawArrow(dragged_edges[i],curve,paper) //just go ahead and redraw the arrow and dots
		edgeIcons[dragged_edges[i].id].push(arrow[0],arrow[1])
		var dots = drawDots(dragged_edges[i],curve,paper)
		edgeIcons[dragged_edges[i].id].push(dots)
	}
	//reset variables
	drag_origin = {cx:0, cy:0, x:0, y:0, id:0} 
	dragged_edges = []
	now_dragging = null
};

//convenience method to do the "click" handling
function clickNode(node, event) {
	if(!event.shiftKey && !now_dragging) //only recenter if we didn't shift-click
		recenter('issue', node.id)
}

//convenience method to do the "click" calculations
function clickEdge(edge){ 
	var curve = getPath(edge); 
	var midPoint = getPathCenter(curve);	
	get_relationship(edge,{curve:curve,midPoint:midPoint},show_modal);
}

//convenience method to do the "hover" calculations
function hoverNode(node){
	if(now_detailing != node.id) {
		get_issue(node, show_details)
		now_detailing = node.id
	}
}

//convenience method to do the "hover" calculations
function hoverEdge(edge){
	// console.log("hovering: "+node.name)
	// curve = getPath(edge);
	// midPoint = getPathCenter(curve);	
	if(now_detailing != edge.id) {	
		get_relationship(edge, {curve:"",midPoint:{x:0,y:0}},show_details)
		now_detailing == edge.id
	}
}



