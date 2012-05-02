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
		.mouseover(function() {this.node.style.cursor='pointer';})//hoverNode(node)})
				// .mouseout(function() {unhover()})
				// .mouseout(function() {unhoverNode(node)})
		.mousedown(function (e) {
			if(e.shiftKey){
				now_dragging = {icon:icon, node:node};
			}
		})
		.drag(dragmove, dragstart, dragend) //enable dragging!

		$(circ.node).qtip(get_node_qtip(node)); //if we want a tooltip

		return icon;  
	}
	else{
		var circ = paper.circle(node.x, node.y, 2)//+(node.weight*6))
		.attr({fill: '#FFD673', 'stroke': '#434343', 'stroke-width': .5})

		var icon = paper.set()
		.push(circ)
		.click(function() { get_issue(node, show_modal)})
		.mouseover(function() {this.node.style.cursor='pointer';})

		$(circ.node).qtip(get_node_qtip(node)); //if we want a tooltip

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
		arrow.insertAfter(e)
		var dots = drawDots(edge, curve, paper)
		dots.insertAfter(e)

		if(hasSelection){
			if((edge.reltype&HIGHLIGHTED)==0){ //if not highlighted
				e.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
				arrow[0].attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
				dots.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
		}}

		var icon = paper.set() //for storing pieces of the line as needed
		.push(e, arrow[0], arrow[1], dots)
		//.mouseover(function() { hoverEdge(edge) })
			//.mouseout(function() { unhoverEdge(edge) })

		$([e.node,arrow[0].node,arrow[1].node]).qtip(get_edge_qtip(edge));

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
		// .mouseover(function() {this.node.style.cursor='pointer';})

		$([e.node,arrow[0].node,arrow[1].node]).qtip(get_edge_qtip(edge));

		return icon;
	}
}

//returns an a curved path for an edge, curving based on which number edge this is
//so for example: the 0th edge could be straight, 1st could curve up, 2nd could curve down, etc
function getPath(edge)
{
	var a = edge.a; //for quick access
	var b = edge.b;

	if(edge.n == 0){ //if the odd curve, then just draw a straight line
		return "M "+a.x+","+a.y+" L "+b.x+","+b.y;
	}
	else{ //otherwise, calculate curves. Control point is some distance along the perpendicular bisector
		var center = [(a.x+b.x)/2, (a.y+b.y)/2];
		var normal = [center[1]-a.y, a.x-center[0]];
		var scale = .3*Math.ceil(edge.n/2); //scale bend based on how many edges there are
		//may need to invert scale if we have two edges going in the same direction
		if(edge.n%2==0 && a.id < b.id || edge.n%2==1 && a.id > b.id)
			scale = scale*-1;

		var control = [center[0]+scale*normal[0], center[1]+scale*normal[1]];
		
		// console.log("control",control)
		return "M"+a.x+","+a.y+" Q "+control[0]+","+control[1]+" "+b.x+","+b.y;
	}

	return ""; //in case we didn't get anything?
}

//returns a path for the edge with a particular thickness (basically calculates two curves offset by width)
function getThickPath(edge, wi){
	var a = edge.a; //for quick access
	var b = edge.b;	
	var unit_normal = getUnitNormal(edge);
	var w = {x:(unit_normal[0]*wi/2), y:(unit_normal[1]*wi/2)}

	if(edge.n == 0){ //if the odd curve, then just draw a straight line
		return "M "+(a.x+w.x)+","+(a.y+w.y)+" L "+(b.x+w.x)+","+(b.y+w.y)+
						"L "+(b.x-w.x)+","+(b.y-w.y)+" L "+(a.x-w.x)+","+(a.y-w.y)+"z"
	}
	else{ //otherwise, calculate curves. Control point is some distance along the perpendicular bisector
		var center = [(a.x+b.x)/2, (a.y+b.y)/2]
		var normal = [center[1]-a.y, a.x-center[0]]
		var scale = .3*Math.ceil(edge.n/2) //scale bend based on how many edges there are
		//may need to invert scale if we have two edges going in the same direction
		if(edge.n%2==0 && a.id < b.id || edge.n%2==1 && a.id > b.id)
			scale = scale*-1

		var control = [center[0]+scale*normal[0], center[1]+scale*normal[1]]
		
		// console.log("control",control)
		return "M"+(a.x+w.x)+","+(a.y+w.y)+" Q "+(control[0]+w.x)+","+(control[1]+w.y)+" "+(b.x+w.x)+","+(b.y+w.y)+
						"L"+(b.x-w.x)+","+(b.y-w.y)+" Q "+(control[0]-w.x)+","+(control[1]-w.y)+" "+(a.x-w.x)+","+(a.y-w.y)+"z"
	}

	return "" //in case we didn't get anything?
}

//returns a transformation string to move the edge perpendicular the given offset
function getUnitNormal(edge){
	var center = [(edge.a.x+edge.b.x)/2, (edge.a.y+edge.b.y)/2]
	var normal = [center[1]-edge.a.y, edge.a.x-center[0]]
	var norm_len = Math.sqrt(normal[0]*normal[0]+normal[1]*normal[1])
	return [normal[0]/norm_len, normal[1]/norm_len]
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
		return "M"+(point.x+ARROW_LENGTH/2)+","+point.y+ "l"+(-1*ARROW_LENGTH)+","+(ARROW_HEIGHT)+ "l"+(0)+","+(-2*ARROW_HEIGHT)+ "z"
	else if(reltype&SUPERSET)
		return "M" + point.x + " " + point.y + " l 0 " + (0 - REC2_EDGE/2) + " l "  + REC2_EDGE + " 0 l 0 " + REC2_EDGE  + " l " + (0 - REC2_EDGE)+" 0 l 0 "+(0 - (REC1_EDGE/2+REC2_EDGE/2))+" l "+(0 - REC1_EDGE)+" 0 l 0 "+REC1_EDGE+" l "+REC1_EDGE+" 0 z";
	else
		return "M"+(point.x+ARROW_LENGTH/2)+","+point.y+ "l"+(-1*ARROW_LENGTH)+","+(ARROW_HEIGHT)+ "l"+(0)+","+(-2*ARROW_HEIGHT)+ "z"
}

//gets the path to draw the symbol inside an arrow
//should this be a text function instead?
function getArrowSymbolPath(point, reltype, symbolSize)
{
	var symbolSize = typeof symbolSize !== 'undefined' ? symbolSize : 2;
	var x_off = symbolSize*1.5
	var y_off = symbolSize*.5

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

function drawArrow(edge, curve, paper, symbolsize)
{
	var a = edge.a
	var b = edge.b
	
	if (edge.reltype&SUPERSET)
		var midPoint = getPathCenter(curve);
	else
		var midPoint = getPathCenter(curve)//, ARROW_LENGTH/2); //midpoint offset by arrow-length

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
	var arrowSymbolPath = getArrowSymbolPath(midPoint, edge.reltype, symbolsize)
	var arrowSymbol = paper.path(arrowSymbolPath, edge.reltype) //draw the symbol on the arrow
		.attr({fill:'#FFFFFF', stroke:'none'})
		.transform('...r'+midPoint.alpha+'t-2.5,0') //apply offset after rotation

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
	// paper.clear() //clear out old drawings

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

var MOVE_TIME = 200
var DISAPPEAR_TIME = 125
var APPEAR_TIME = 125
var SEP_TIME = 50

//animate change between old nodes/edges and new nodes/edges
function animateElements(fromNodes, fromEdges, toNodes, toEdges, paper)
{
	paper.clear() //start blank
	easing = "linear" //either this or backOut look nice IMO

	nodeIcons = {} //reset the lists
	edgeIcons = {}

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

				oldSymbol = icon.splice(1,3) //get rid of old arrows and dots
				toAnimate.push({el:oldSymbol, anim:tempVanish})
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
			}
			else{
				var curveMovement = Raphael.animation({'path':getPath(toEdge)},MOVE_TIME,easing)
					.delay(DISAPPEAR_TIME+SEP_TIME)
				toAnimate.push({el:icon, anim:curveMovement})
			}
			edgeIcons[toEdge.id] = icon //add to the list no matter what
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
			edgeIcons[toEdge.id] = icon //add to the list
			//console.log("adding",toEdge.name,"to edgeIcons with index",toEdge.id)
		}
	}  

	//move the old nodes into the new
	for(var i=0, len=fromNodes['keys'].length; i<len; i++)
	{
		var fromNode = fromNodes[fromNodes['keys'][i]] //easy access
		var toNode = toNodes[fromNode['id']] //corresponding toNode (one that has id as key; could also just check if has the same key)

		if(typeof toNode === 'undefined'){ //if no toNode
			var icon = drawNode(fromNode, paper)
			toAnimate.push({el:icon, anim:disappear})
		}
		else{
			var icon = drawNode(toNode, paper)
			.attr({ cx: fromNode.x, cy: fromNode.y, x: fromNode.x, y: fromNode.y+T_OFF }) //put at old position initially
			// fromNode.x = toNode.x; fromNode.y = toNode.y; //change the stored location for future querying (interaction)
			var move = Raphael.animation({ cx: toNode.x, cy: toNode.y, x: toNode.x, y: toNode.y+T_OFF }, MOVE_TIME, easing)
				.delay(DISAPPEAR_TIME+SEP_TIME)
			toAnimate.push({el:icon, anim:move})
			nodeIcons[toNode.id] = icon //add to the list
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
			nodeIcons[toNode.id] = icon //add to the list
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

	//console.log(nodeIcons, edgeIcons)
} //animateNodes

//methods to control dragging
var dragstart = function (x,y,event) 
{
	if(event.shiftKey && now_dragging) {
		this.ox = 0;
		this.oy = 0;

		for(var i=0, len=currEdges['keys'].length; i<len; i++)
		{
			var edge = currEdges[currEdges['keys'][i]]
			if(edge.a == now_dragging.node || edge.b == now_dragging.node){
				// console.log(edge.name, edge.id, edgeIcons[edge.id])
				dragged_edges.push(edge) //SHOULD THIS BE STORING THE ICONS RATHER THAN THE EDGES?? NO, SINCE WE'LL WANT TO ADJUST
				oldSymbol = edgeIcons[edge.id].splice(1,3) //remove the symbol, since we're not moving it
				oldSymbol.remove()
			}
		}
	}
};
var dragmove = function (dx,dy,x,y,event) 
{
	if(event.shiftKey && now_dragging) {
		trans_x = dx-this.ox
		trans_y = dy-this.oy
		now_dragging.node.x += trans_x
		now_dragging.node.y += trans_y //move the node itself; this will move the appropriate edges
		now_dragging.icon.transform("...t"+trans_x+","+trans_y)
		this.ox = dx;
		this.oy = dy;

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
		$([arrow[0].node,arrow[1].node]).qtip(get_edge_qtip(dragged_edges[i])); //add pop-up handler...
	}
	//reset variables
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
		get_issue(node, show_modal)
		//get_issue(node, show_details)
		now_detailing = node.id
	}
}

//what to do when we stop hoving over something
function unhover(){
	now_detailing = 0
	hide_modal()
}

//convenience method to do the "hover" calculations
function hoverEdge(edge){
	// console.log("hovering: "+node.name)
	// curve = getPath(edge);
	// midPoint = getPathCenter(curve);	
	if(now_detailing != edge.id) {	
		var curve = getPath(edge); 
		var midPoint = getPathCenter(curve);	
		get_relationship(edge,{curve:curve,midPoint:midPoint},show_modal);
		//get_relationship(edge, {curve:"",midPoint:{x:0,y:0}},show_details)
		now_detailing == edge.id
	}
}



