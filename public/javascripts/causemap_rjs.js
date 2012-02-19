/*****
** This file includes methods for drawing the graph on a Raphael.js canvas
*****/

var T_OFF = 9 //txt offset
var ARROW_LENGTH = 20 // arrowhead length
var ARROW_HEIGHT = 8 // arrowhead height
var edge_colors = {'increases':'#C06B82','decreases':'#008FBD','superset':'#BEBEBE'}


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

		return icon;  
	}
}

//details on drawing/laying out an edge (a single line/relationship)
function drawEdge(edge, paper){
	if(!compact){	
		a = edge.a;
		b = edge.b;

		curve = getPath(edge) //get the curve's path
		midPoint = getPathCenter(curve, ARROW_LENGTH/2); //midpoint offset by arrow-length
		if(a.x <= b.x && b.y <= a.y){ //sometimes we need to flip the alpha, seems to be covered by this
			if(!(b.y == a.y && midPoint.alpha > 360)){ //handle special case, if b.y == a.y, seems to work 
				//console.log("flipped",edge.name)
				midPoint.alpha = midPoint.alpha+180 % 360 //flip 180 degrees so pointed in right direction
				//console.log("alpha after flip",midPoint.alpha)
		}}
		arrowPath = getArrowPath(midPoint)
		arrowSymbolPath = getArrowSymbolPath(midPoint, edge.reltype)

		e = paper.path(curve)
			.attr({'stroke-width':2})
		arrow = paper.path(arrowPath)
			.attr({stroke:'none'})
			.rotate(midPoint.alpha, midPoint.x, midPoint.y) //draw the arrowhead
		arrowSymbol = paper.path(arrowSymbolPath)
			.attr({fill:'#FFFFFF', stroke:'none'})
			.rotate(midPoint.alpha, midPoint.x, midPoint.y)

		//set attributes based on relationship type (bitcheck with constants)
		if(edge.reltype&INCREASES){
			e.attr({stroke:edge_colors['increases']})
			arrow.attr({fill:edge_colors['increases']})
		}
		else if(edge.reltype&SUPERSET){
			e.attr({stroke:edge_colors['superset']})
			arrow.attr({fill:edge_colors['superset']})	
		}
		else{ //if decreases
			e.attr({stroke:edge_colors['decreases']})
			arrow.attr({fill:edge_colors['decreases']});	
		}

		//if(edge.reltype&HIGHLIGHTED)
			//e.glow({width:4,fill:false,color:'#FFFF00',opacity:1}) //would have to animate this as well it seems...

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
			e.attr({stroke:edge_colors['increases']}) //BA717F
		else if(edge.reltype&SUPERSET)
			e.attr({stroke:edge_colors['superset']}) //BBBBBB change for superset
		else //if decreases
			e.attr({stroke:edge_colors['decreases']}) //408EB8, 54B9D9
		//if(edge.reltype&HIGHLIGHTED)
			//e.glow({width:4,fill:false,color:'#FFFF00',opacity:1}) //would have to animate this as well it seems...

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

	//-----------------Calculate the third point of Equilateral Triangle on the coordinate as the control point------------------
	pivotPoint = (b.x > a.x) ? a : b
	dx = b.x - a.x
	dy = b.y - a.y 
	lengthAB = Math.sqrt(dx*dx + dy*dy)
	angleAB = Math.atan(dy/dx)

	//should handle case where a.y and b.y are the same (instead put control point elsewhere?)

	PI2 = Math.PI/180

	if(edge.n == 0){ //Curve "0" -- straight line if we want it
		return "M "+a.x+","+a.y+" L "+b.x+","+b.y
	}
	

	
	// else if(Math.abs(edge.n)%2 == 1){ //if odd, curve up		
	// 
	// }
	// else if(Math.abs(edge.n)%2 == 0){ //if even, curve down
	//  
	// }
	
	
	if(Math.abs(edge.n) == 1){ //Curve "1"
		if(edge.n > 0){
			ctrlx = lengthAB / (2 * Math.cos(20 * PI2)) * Math.cos(angleAB + 20 * PI2) + pivotPoint.x
			ctrly = lengthAB / (2 * Math.cos(20 * PI2)) * Math.sin(angleAB + 20 * PI2) + pivotPoint.y
		}
		else{
			//change to flip the curve
			ctrlx = lengthAB / (2 * Math.cos(20 * PI2)) * Math.cos(angleAB + 20 * PI2) + pivotPoint.x
			ctrly = lengthAB / (2 * Math.cos(20 * PI2)) * Math.sin(angleAB + 20 * PI2) + pivotPoint.y
		}
		return "M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y
	}

	if(Math.abs(edge.n) == 2){ //Curve "2"
		if(edge.n > 0){
			ctrlx = lengthAB / (2 * Math.cos(-30 * PI2)) * Math.cos(angleAB + 30 * PI2) + pivotPoint.x
			ctrly = lengthAB / (2 * Math.cos(-30 * PI2)) * Math.sin(angleAB + 30 * PI2) + pivotPoint.y
		}
		else{
			//change to flip the curve
			ctrlx = lengthAB / (2 * Math.cos(-30 * PI2)) * Math.cos(angleAB - 30 * PI2) + pivotPoint.x
			ctrly = lengthAB / (2 * Math.cos(-30 * PI2)) * Math.sin(angleAB - 30 * PI2) + pivotPoint.y
		}
		return "M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y

		// if(edge.n > 0){
		// 	ctrlx = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.cos(angleAB + 45 * Math.PI/180) + pivotPoint.x
		// 	ctrly = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.sin(angleAB + 45 * Math.PI/180) + pivotPoint.y
		// } 
		// else{
		// 	//change to flip the curve
		// 	ctrlx = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.cos(angleAB + 45 * Math.PI/180) + pivotPoint.x
		// 	ctrly = lengthAB / (2 * Math.cos(45 * Math.PI/180)) * Math.sin(angleAB + 45 * Math.PI/180) + pivotPoint.y
		// }
		// return "M"+a.x+","+a.y+" Q " + ctrlx + ","+ctrly+" "+b.x+","+b.y
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
//this needs to include a switch if the guy is going the other direction...
function getArrowPath(point)
{
	return "M" + point.x + " " + point.y + " L" + (point.x - ARROW_LENGTH) + " " + (point.y - ARROW_HEIGHT) + " L" + (point.x - ARROW_LENGTH) + " " + (point.y + ARROW_HEIGHT) + " L" + point.x + " " + point.y;
}


//gets the path to draw the symbol inside an arrow
//should this be a text function instead?
function getArrowSymbolPath(point, reltype)
{
	symbolSize = 3;

	if(reltype&INCREASES){
		return "M " + (point.x-9) + " " + (point.y+2) + " l 0 " + (0 - symbolSize) + " l " + (0 - symbolSize) + " 0 l 0 " + (0 - symbolSize) + " l " + (0 - symbolSize) + " 0 l 0 " + symbolSize + " l " + (0 - symbolSize) + " 0 l 0 " + symbolSize + " l " + symbolSize + " 0 l 0 " + symbolSize + " l " + symbolSize + " 0 l 0 " + (0 - symbolSize);
	}
	else if(reltype&SUPERSET){
		return "M " + (point.x-9) + " " + (point.y+2); //  should delete this object or make another icon !
	}
	else{  //if decreases 
		return "M " + (point.x-9) + " " + (point.y+2) + " l 0 " + (0 - symbolSize) + " l " + (0 - symbolSize*3) + " 0 l 0 " + symbolSize;
	}
	
	return "" //if problem
}


//Interaction functions, for when we click on things. Variables passed are things we're going to use
function clickNode(node){
	//do form submit without needing to make the form!
	$.ajax({
		url: '/mapvisualizations',
		data: {do:'get_issue',id:node.id, x:node.x, y:node.y},
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
	arrowPath = getArrowPath(midPoint)
	
	
	
	$.ajax({
		url: '/mapvisualizations',
		data: {do:'get_relation',id:edge.id, curve:curve, x:midPoint.x, y:midPoint.y},
		complete: function(data) {show_modal(data);},
		dataType: 'script'
	});

	console.log(edge.name+"\n"+curve);
	console.log(midPoint)

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
				arrowPath = getArrowPath(midPoint)
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





