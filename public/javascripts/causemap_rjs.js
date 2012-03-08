/*****
** This file includes methods for drawing the graph on a Raphael.js canvas
*****/

var T_OFF = 9 //txt offset

var EXPAND_DIST_TO_ICON = 3 	// distance from EXPAND symbol to EDGE ICON
var EXPAND_DIST_BETWEEN = 5 	// distance between dots 
var EXPAND_RADIUS = 2.5     	// radius of EXPAND icon dots
var NUM_OF_DOTS = 3		// number of dots each side of EXPAND symbol

var REC1_EDGE = 9 // arrowhead length
var REC2_EDGE = 6.5 // arrowhead height
var ARROW_LENGTH = 15 // arrowhead length
var ARROW_HEIGHT = 6 // arrowhead height

var EDGE_COLORS = {'increases':'#C06B82','decreases':'#008FBD','superset':'#BBBBBB'}
var DESEL_OP = 0.4

//details on drawing/laying out a node
function drawNode(node, paper){
	if(!compact){

		txt = paper.text(node.x, node.y+T_OFF, node.name)
		circ = paper.circle(node.x, node.y, 5)//+(node.weight*6))
		.attr({
			fill: '#FFD673', 'stroke': '#434343', 'stroke-width': 1,
		})

		icon = paper.set()
		.push(circ,txt)
		.click(function() { clickNode(node)})
		.mouseover(function() {this.node.style.cursor='pointer'})

		if(hasSelection){
			if(!node.h) //if not highlighted
				icon.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
		}

		$(circ.node).qtip({content:{text:node.name}}); //if we want a tooltip

		return icon;  
	}
	else{
		circ = paper.circle(node.x, node.y, 2)//+(node.weight*6))
		.attr({fill: '#FFD673', 'stroke': '#434343', 'stroke-width': .5})

		icon = paper.set()
		.push(circ)
		.click(function() { clickNode(node)})
		.mouseover(function() {this.node.style.cursor='pointer';})  

		$(circ.node).qtip({content:{text:node.name}}); //if we want a tooltip

		return icon;  
	}
}

//details on drawing/laying out an edge (a single line/relationship)
function drawEdge(edge, paper){
	if(!compact){	
		a = edge.a;
		b = edge.b;

		curve = getPath(edge) //get the curve's path		
		// console.log(edge.name)
		// console.log(curve)
		e = paper.path(curve)
			.attr({'stroke-width':2})
		
		if (edge.reltype&INCREASES)
			midPoint = getPathCenter(curve, ARROW_LENGTH/2); //midpoint offset by arrow-length
		else if (edge.reltype&SUPERSET)
			midPoint = getPathCenter(curve);
		else
			midPoint = getPathCenter(curve, ARROW_LENGTH/2); //midpoint offset by arrow-length

		if(a.x <= b.x && b.y <= a.y){ //sometimes we need to flip the alpha, seems to be covered by this
			if(!(b.y == a.y && midPoint.alpha > 360)){ //handle special case, if b.y == a.y, seems to work 
				//console.log("flipped",edge.name)
				midPoint.alpha = midPoint.alpha+180 % 360 //flip 180 degrees so pointed in right direction
				//console.log("alpha after flip",midPoint.alpha)
		}}

		arrowPath = getArrowPath(midPoint, edge.reltype)
		arrow = paper.path(arrowPath)
			.rotate(midPoint.alpha, midPoint.x, midPoint.y) //draw the arrowhead


		if (edge.reltype&INCREASES)		
			arrow.attr({stroke:'#FFFFFF', 'stroke-width': 2})
		else if (edge.reltype&SUPERSET)
			arrow.attr({stroke:'#FFFFFF', 'stroke-width': 2})
		else
			arrow.attr({stroke:'#FFFFFF', 'stroke-width': 2})

		arrowSymbolPath = getArrowSymbolPath(midPoint, edge.reltype)
		arrowSymbol = paper.path(arrowSymbolPath, edge.reltype)
			.attr({fill:'#FFFFFF', stroke:'none'})
			.rotate(midPoint.alpha, midPoint.x, midPoint.y)

		//set attributes based on relationship type (bitcheck with constants)
		if(edge.reltype&INCREASES){
			e.attr({stroke:EDGE_COLORS['increases']})
			arrow.attr({fill:EDGE_COLORS['increases']})
		}
		else if(edge.reltype&SUPERSET){
			e.attr({stroke:EDGE_COLORS['superset']})
			arrow.attr({fill:EDGE_COLORS['superset']})
		}
		else{ //if decreases
			e.attr({stroke:EDGE_COLORS['decreases']})
			arrow.attr({fill:EDGE_COLORS['decreases']});	
		}

		if(hasSelection){
			if((edge.reltype&HIGHLIGHTED)==0){ //if not highlighted
				e.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
				arrow.attr({'opacity':DESEL_OP,'stroke-opacity':DESEL_OP})
		}}
// Expandable Demo START

	r = Math.floor(Math.random()*11);
	if (r < 4) {
		var expand_cr = [];
		var expand_cl = [];
		pathLength = Raphael.getTotalLength(curve);


		if(edge.reltype&INCREASES){
			for(i=0; i<NUM_OF_DOTS; i++) {
				expand_cr[i] = Raphael.getPointAtLength(curve,pathLength/2 + ARROW_LENGTH/2 + EXPAND_DIST_TO_ICON + EXPAND_DIST_BETWEEN*i);
				expand_cl[i] = Raphael.getPointAtLength(curve,pathLength/2 - ARROW_LENGTH/2 - EXPAND_DIST_TO_ICON - EXPAND_DIST_BETWEEN*i);
			}
		}
		else if(edge.reltype&SUPERSET){
			for(i=0; i<NUM_OF_DOTS; i++) {
				expand_cr[i] = Raphael.getPointAtLength(curve,pathLength/2 + REC2_EDGE + EXPAND_DIST_TO_ICON + EXPAND_DIST_BETWEEN*i);
				expand_cl[i] = Raphael.getPointAtLength(curve,pathLength/2 - REC1_EDGE - EXPAND_DIST_TO_ICON - EXPAND_DIST_BETWEEN*i);
			}
		}
		else{ //if decreases
			for(i=0; i<NUM_OF_DOTS; i++) {
				expand_cr[i] = Raphael.getPointAtLength(curve,pathLength/2 + ARROW_LENGTH/2 + EXPAND_DIST_TO_ICON + EXPAND_DIST_BETWEEN*i);
				expand_cl[i] = Raphael.getPointAtLength(curve,pathLength/2 - ARROW_LENGTH/2 - EXPAND_DIST_TO_ICON - EXPAND_DIST_BETWEEN*i);
			}
		}

		var allDots = paper.set();
		for(var i=0; i<NUM_OF_DOTS; i++) {
			allDots.push(paper.circle(expand_cr[i].x, expand_cr[i].y, EXPAND_RADIUS),
			paper.circle(expand_cl[i].x, expand_cl[i].y, EXPAND_RADIUS));
		}


		if(edge.reltype&INCREASES){
			allDots.attr({stroke:"#FFFFFF",fill:EDGE_COLORS['increases'],'stroke-width': '2'})			
		}
		else if(edge.reltype&SUPERSET){
			allDots.attr({stroke:"#FFFFFF",fill:EDGE_COLORS['superset'],'stroke-width': '2'})
		}
		else{ //if decreases
			allDots.attr({stroke:"#FFFFFF",fill:EDGE_COLORS['decreases'],'stroke-width': '2'})
		}
		//st.attr({stroke:"#FFFFFF", fill:"#000000"});
	}

// END of Expandable Demo

		icon = paper.set() //for storing pieces of the line as needed
		.push(e, arrow, arrowSymbol)
		.click(function() { clickEdge(edge)})
		.mouseover(function() {this.node.style.cursor='pointer';})

		$([e.node,arrow.node,arrowSymbol.node]).qtip({
			content:{text:edge.name},
			position:{target: 'mouse', adjust:{y:5}}
		});

		return icon;
	}
	else{	
		curve = getPath(edge) //get the curve's path
		e = paper.path(curve).attr({'stroke-width':1}) //base to draw

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

		icon = paper.set() //for storing pieces of the line as needed
		.push(e)
		.click(function() { clickEdge(edge)})
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
	a = edge.a //for quick access
	b = edge.b

	if(edge.n == 0){ //if the odd curve, then just draw a straight line
		return "M "+a.x+","+a.y+" L "+b.x+","+b.y
	}
	else{ //otherwise, calculate curves. Control point is some distance along the perpendicular bisector
		center = [(a.x+b.x)/2, (a.y+b.y)/2]
		normal = [center[1]-a.y, a.x-center[0]]
		scale = .3*Math.ceil(edge.n/2) //scale bend based on how many edges there are
		control = [center[0]+scale*normal[0], center[1]+scale*normal[1]]
		
		// console.log("control",control)
		return "M"+a.x+","+a.y+" Q "+control[0]+","+control[1]+" "+b.x+","+b.y
	}

	return "" //in case we didn't get anything?
}

function getPathCenter(path, offset, flip)
{
	offset = typeof offset !== 'undefined' ? offset : 0;
	flip = typeof offset !== 'undefined' ? flip : false;

	pathLength = Raphael.getTotalLength(path);
	midPoint = Raphael.getPointAtLength(path,pathLength/2 + offset);

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


//Interaction functions, for when we click on things. Variables passed are things we're going to use
function clickNode(node){
	//do form submit without needing to make the form!
	$.ajax({
		url: '/mapvisualizations',
		data: {'do':'get_issue',id:node.id, x:node.x, y:node.y},
		complete: function(data) {show_modal(data);},
		dataType: 'script'
	});

	console.log(node.name);
	// $('#clickForm').children('#do').attr({value:'show_issue'});
	// $('#clickForm').append('<input name="id" value='+node.id+'>');
	// $('#clickForm').submit();//button.trigger("click");
}

function clickEdge(edge){
	curve = getPath(edge);
	midPoint = getPathCenter(curve);	
	// arrowPath = getArrowPath(midPoint)
	
	$.ajax({
		url: '/mapvisualizations',

		data: {'do':'get_relation',id:edge.id, curve:curve, x:midPoint.x, y:midPoint.y},

		complete: function(data) {show_modal(data);},
		dataType: 'script'
	});

	console.log(edge.name+"\n"+curve);

	// $('#clickForm').children('#do').attr({value:'get_relation'});
	// $('#clickForm').append('<input name="id" value='+edge.id+'>');
	// $('#clickForm').append('<input name="curve" value="'+curve+'">');
	// $('#clickForm').submit();//button.trigger("click");
}


//a basic draw function
//draw the given nodes and edges on the given paper (a Raphael object)
//nodes and edges are objects of objects; includes 'keys' as an array of the keys for iterating
function drawElements(nodes, edges, paper)
{
	paper.clear() //clear out old drawings

	//draw edges (below the nodes)
	for(var i=0, len=edges['keys'].length; i<len; i++){
		edge = edges[edges['keys'][i]]
		drawEdge(edge, paper)
	}

	//draw nodes
	for(var i=0, len=nodes['keys'].length; i<len; i++){
		node = nodes[nodes['keys'][i]] //easy access
		drawNode(node, paper)
	}
}

//animate change between old nodes/edges and new nodes/edges
function animateElements(fromNodes, fromEdges, toNodes, toEdges, paper)
{
	paper.clear() //start blank
	easing = "backOut" //either this or linear look nice

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
			if(!compact){ //not compact so we need to move arrows as well
				//get the curves for the new path 
				curve = getPath(toEdge) //get the curve's path
				midPoint = getPathCenter(curve, ARROW_LENGTH/2); //midpoint offset by arrow-length
				if(a.x <= b.x && b.y <= a.y){ //sometimes we need to flip the alpha, seems to be covered by this
					if(!(b.y == a.y && midPoint.alpha > 360)){ //handle special case, if b.y == a.y, seems to work 
						//console.log("flipped",edge.name)
						midPoint.alpha = midPoint.alpha+180 % 360 //flip 180 degrees so pointed in right direction
						//console.log("alpha after flip",midPoint.alpha)
				}}
				arrowPath = getArrowPath(midPoint, toEdge.reltype)
				arrowSymbolPath = getArrowSymbolPath(midPoint, toEdge.reltype)
				transform = 'r'+midPoint.alpha+','+midPoint.x+','+midPoint.y

				icon[0].animate({'path':curve},1000,easing)
				icon[1].attr({'path':arrowPath,'transform':transform,'opacity':0, 'fill-opacity':0})
				.animate({'opacity':1, 'fill-opacity':1}, 1000, 'linear') //hack because tranform doesn't animate smoothly
				icon[2].attr({'path':arrowSymbolPath,'transform':transform,'opacity':0, 'fill-opacity':0})
				.animate({'opacity':1, 'fill-opacity':1}, 1000, 'linear')
			}
			else{
				icon.animate({'path':getPath(toEdge)},1000,easing)
			}
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
			fromNode.x = toNode.x; fromNode.y = toNode.y; //change the stored location for future querying (interaction)
			icon.animate({ cx: toNode.x, cy: toNode.y, x: toNode.x, y: toNode.y+T_OFF }, 1000, easing)
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

} //animateNodes





