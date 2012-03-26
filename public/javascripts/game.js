/// THIS FILE CONTAINS THE JAVASCRIPT FOR THE GAME, OVERWRITING causemap_rjs AND mapvizualization_index WHERE APPROPRIATE

//details on drawing/laying out a node
function drawNode(node, paper){
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
		.mouseover(function() {this.node.style.cursor='pointer';})//hoverNode(node)})
		.mousedown(function (e) {now_dragging = {icon:icon, node:node};})
		.drag(dragmove, dragstart, dragend) //enable dragging!

		$(circ.node).qtip(get_node_qtip(node)); //if we want a tooltip

		return icon;  
}

//details on drawing/laying out an edge (a single line/relationship)
function drawEdge(edge, paper){
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

		var icon = paper.set() //for storing pieces of the line as needed
		.push(e, arrow[0], arrow[1], dots)

		$([e.node,arrow[0].node,arrow[1].node]).qtip(get_edge_qtip(edge));

		return icon;
}


//methods to control dragging
var dragstart = function (x,y,event) 
{
	if(now_dragging) {
		drag_origin.cx = now_dragging.icon[0].attr('cx'); //store the original locations
	  drag_origin.cy = now_dragging.icon[0].attr('cy');
		drag_origin.x = now_dragging.icon[1].attr('x');
		drag_origin.y = now_dragging.icon[1].attr('y');

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
	if(now_dragging) {
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


//layout details for the node qtip
function get_node_qtip(node) {
	return {
		content:{
			text: '<div id="relation_qtip"><div class="formcontentdiv"><div class="heading">' + 
							node.name + '</div></div></div>'
		},
		position: {
			// my: 'top center',  // Position my top left...
			// at: 'bottom center', // at the bottom right of...
			target: 'mouse',
			adjust: {y:4}
		},
		style: {
			classes: 'ui-tooltip-light ui-tooltip-shadow'
		}
	};
}

//layout details for the edge qtip
function get_edge_qtip(edge) {
	return {
		content:{
			text: '<div id="relation_qtip"><div class="formcontentdiv"><div class="heading">' + 
							edge.name + '</div></div></div>'
			// text: 'Loading '+edge.name+'...',
			// ajax:{
			// 	url: 'mapvisualizations/qtip',
			// 	type: 'GET',
			// 	data: {t: 'relation', id: edge.id}
			// }
		},
		position: {
			// my: 'top center',  // Position my top left...
			// at: 'bottom center', // at the bottom right of...
			target: 'mouse',
			adjust: {y:4}
		},
		style: {
			classes: 'ui-tooltip-light ui-tooltip-shadow'
		}
	};	
}
