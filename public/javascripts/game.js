/// THIS FILE CONTAINS THE JAVASCRIPT FOR THE GAME, OVERWRITING causemap_rjs AND mapvizualization_index WHERE APPROPRIATE

/* Random NOTES
//arrowhead svg
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
    <path id="arrow" fill="#090BAB" d="M 50,100 L 0,0 L 50,30 L 100,0" />
</svg>
*/

var startBox;
var now_building = null //the thing we're dragging

//sets up initial boxes and stuff for the game
function drawInitGame(paper){
	startBox = paper.rect(paper_size.width-203,150,200,paper_size.height-150-3).attr({'stroke': '#000000', 'stroke-width':3})
	var boxLabel = paper.text(paper_size.width-203+5,150+15,'Concepts').attr({
		'text-anchor':'start', 
		'font':'lucida grande', 'font-family':'sans-serif',
		'font-size':24, 'font-weight':'bold',
		'fill':'#BEBEBE'
	})
}

//details on drawing/laying out a node
function drawNode(node, paper){
		var island_num = Math.floor(Math.random()*4)
		// var coast = paper.path(ISLAND_PATHS[island_num]).attr({
		// 	'stroke': '#b3eeee', 'stroke-width': 10,
		// });
		var coast = paper.circle(node.x,node.y,20).attr({
			'fill': '#b3eeee','stroke-width':0
		})
		
		var island = paper.path(ISLAND_PATHS[island_num]).attr({
			fill: '#FFD673', 'stroke': '#434343', 'stroke-width': 1,
		});
		var bb = island.getBBox();
		var trans_string = "t"+(node.x-(bb.x+bb.width/2))+","+(node.y-(bb.y+bb.height/2))
		island.transform(trans_string)
		//coast.transform(trans_string)
		

		var content = node.name;
		if(content.length > 15)
			content = content.substring(0,15)+"..."
		var txt = paper.text(node.x, node.y+T_OFF, content)
		// _textWrapp(txt,80)

		var icon = paper.set()
		.push(island,txt)
		.mouseover(function() {this.node.style.cursor='move';})//hoverNode(node)})
		.mousedown(function(e) {now_dragging = {icon:icon, node:node};})
		.drag(dragmove, dragstart, dragend) //enable dragging!

		icon.push(coast)
		coast.mouseover(function() {this.node.style.cursor='crosshair';})
		.mousedown(function(e) {now_building = {start_node:node};})
		.drag(buildmove, buildstart, buildend)

		$(island.node).qtip(get_node_qtip(node)); //if we want a tooltip
		$(coast.node).qtip("drag to create a path");

		return icon;  
}

//details on drawing/laying out an edge (a single line/relationship)
function drawEdge(edge, paper){
		var a = edge.a;
		var b = edge.b;

		var curve = getPath(edge) //get the curve's path		
		var e = paper.path(curve).attr({'stroke-width':2}).toBack()
		
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
	if(now_dragging) {
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
	}
	//reset variables
	dragged_edges = []
	now_dragging = null
};


//methods to control building via dragging
var buildstart = function (x,y,event) 
{
	// console.log("buildstart",x,y, event)
	if(now_building) { //make sure we clicked something
		now_building.target_node = {id:-1, x:x-CANVAS_OFFSET.left, y:y-CANVAS_OFFSET.top} //where we're drawing to, relative to canvas
		now_building.edge = {id:-1, a:now_building.start_node, b:now_building.target_node, reltype:1, n:0} //the edge we're making

		now_building.icon = drawEdge(now_building.edge,paper)
		// paper.circle(x,y,5)
		this.ox = 0;
		this.oy = 0;
	}
};
var buildmove = function (dx,dy,x,y,event) 
{
	// console.log("buildmove",dx,dy,x,y,event)
	if(now_building) {
		now_building.target_node.x = x-CANVAS_OFFSET.left //don't forget the offset to bring mouse in line!
		now_building.target_node.y = y-CANVAS_OFFSET.top
		now_building.selected_node = null;
		
		//snap to targets!!
		for(var i=0, len=currNodes['keys'].length; i<len; i++){
			var node = currNodes[currNodes['keys'][i]] //easy access
			var icon = nodeIcons[node.id]
			var bb = icon[2].getBBox() //compare to the bounding box of the circle currently
			if(	now_building.start_node != node &&
					now_building.target_node.x > bb.x && now_building.target_node.x < bb.x+bb.width &&
					now_building.target_node.y > bb.y && now_building.target_node.y < bb.y+bb.height ){ //if inside the bounding box
				// console.log("snapped to",node.name)
				now_building.target_node.x = node.x
				now_building.target_node.y = node.y
				now_building.selected_node = node //store who we've 'selected'
				break
			}
		}
		
		now_building.icon.remove()
		now_building.icon = drawEdge(now_building.edge,paper) //redraw the edge (brute force redraw)
	}
};
var buildend = function (x,y,event) 
{	
	// console.log("buildend")
	if(now_building) {
		if(now_building.selected_node){
			//now_building.icon[0].toBack() //push the line to the back, to clean up display
			
			//set up the edge
			var edge = now_building.edge
			edge.b = now_building.selected_node;
			edge.id = currEdges['keys'].length+1; //give id that's just a count (1...n)
			edge.name = edge.a.name+(edge.reltype&INCREASES ? ' increases ' : ' decreases ')+edge.b.name
			var key = edge.a.id+(edge.reltype&INCREASES ? 'i' : 'd')+edge.b.id

			if(currEdges[key]){ //if edge already exists
				edge.id = currEdges[key].id; //replace the old id
				edgeIcons[edge.id].remove() //get rid of the old icon
			}
			else{
				currEdges['keys'].push(key) //only push the key if this is a new edge (and so we need to add it to the list)
				edge.id = currEdges['keys'].length; //give id that's just a count (1...n)
			}
			currEdges[key] = edge

			//set up the icon
			var icon = now_building.icon
			edgeIcons[edge.id] = icon
			$([icon[0].node,icon[1].node,icon[2].node]).qtip(get_edge_qtip(edge)); //add handlers

			//figure out if we need to adjust the 'n'
			var tobend = []
			for(var i=0, len=currEdges['keys'].length; i<len; i++){
				var e = currEdges[currEdges['keys'][i]]
				if( (e.a == edge.a && e.b == edge.b) || (e.a == edge.b && e.b == edge.a) )
					tobend.push(e)
			}
			for(var i=1, len=tobend.length; i<=len; i++){
				var e = tobend[i-1], oldn = e.n
				if(i==len) //if last guy
					e.n = (i%2==0 ? i : 0) //then he gets 0 if even, number otherwise
				else
					e.n = i //give them their count
				if(e.n != oldn) { //if our n changed
					edgeIcons[e.id].remove()
					edgeIcons[e.id] = drawEdge(e, paper)
				}
			}
		}
		else {
			now_building.icon.remove() //remove the icon, cause we didn't select anything
		}
	}

	//reset variables
	now_building = null
};



//layout details for the node qtip
function get_node_qtip(node) {
	return {
		content:{
			text: '<div id="relation_qtip"><div class="formcontentdiv"><div class="heading">Concept: ' + 
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


/**
 * adapted from
 * http://stackoverflow.com/questions/3142007/how-to-either-determine-svg-text-box-width-or-force-line-breaks-after-x-chara
 * @param t a raphael text shape
 * @param width - pixels to wrapp text width
 * modify t text adding new lines characters for wrapping it to given width.
 */
_textWrapp = function(t, width, max_length) {
		var wrapped = false;
    var content = t.attr("text");
    var abc="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    t.attr({'text-anchor': 'start', "text": abc});
    var letterWidth=t.getBBox().width / abc.length;
    t.attr({"text": content});
    var words = content.split(" "), x=0, s=[];
    for ( var i = 0; i < words.length; i++) {
        var l = words[i].length;
        if(x+l>width) {
            s.push("\n")
            x=0;
						wrapped = true;
        }
        else {
            x+=l*letterWidth;
        }
        s.push(words[i]+" ");
    }
    t.attr({"text": s.join("")});
		// if(!wrapped)
		t.attr({'text-anchor':'middle'});
};

var ISLAND_PATHS = [
	"m 0,0 c -1.91236,1.98339 -2.80708,3.61839 -5.61026,3.81571 -2.80316,0.19731 -4.31423,-1.70427 -6.79667,-3.14318 -2.48243,-1.43893 -6.42395,-1.98616 -7.70867,-4.3606 -1.28472,-2.37444 1.6344,-5.25816 2.13987,-7.95092 0.50547,-2.69276 -1.90255,-6.34614 0.0583,-8.26862 1.96082,-1.92249 6.30872,0.7799 9.18689,0.76381 2.87817,-0.016 6.79908,-2.90242 9.09492,-1.17821 2.29585,1.72422 0.79516,5.56878 1.48178,8.1391 0.68663,2.57031 2.58603,4.8535 1.98816,7.58076 -0.59787,2.72726 -1.92192,2.61877 -3.83429,4.60215 z",
	"m 0,0 c -2.55529,-1.74975 -3.49186,-3.24455 -3.97569,-6.18062 -0.48384,-2.93608 8.4e-4,-2.69556 1.69371,-5.42447 1.69281,-2.72892 -2.342,-7.29109 0.77652,-8.10212 3.1185,-0.81105 4.87228,1.23266 7.67865,1.82399 2.80636,0.59134 10.6187,-2.64803 12.47562,-0.14235 1.85693,2.50569 -0.82957,2.34996 -0.69902,5.6157 0.13054,3.26575 2.79614,8.75285 1.97668,11.47121 -0.81946,2.71838 -6.85279,1.10439 -9.18567,3.31862 -2.33288,2.21422 -3.57679,2.18539 -6.52846,1.56554 -2.95166,-0.61986 -1.65707,-2.19576 -4.21234,-3.9455 z",
	"m 0,0 c -1.48637,1.5628 -0.73525,2.93289 -2.83352,3.28257 -2.09825,0.34968 -5.81339,-1.59274 -7.90259,-1.78665 -2.0892,-0.19393 -4.52388,2.56908 -6.38447,1.51744 -1.86057,-1.05161 2.00929,-5.37364 0.96399,-7.25919 -1.04531,-1.88553 -3.28922,-2.68468 -3.6286,-4.85667 -0.33937,-2.172 1.77845,-2.78699 2.54256,-4.84833 0.7641,-2.06134 -2.18913,-4.70518 -0.66511,-6.22 1.52404,-1.51481 6.89374,2.06774 9.12329,1.81582 2.22954,-0.25193 3.04729,-2.91462 5.07328,-2.67444 2.02599,0.24019 2.10648,2.05826 3.71392,3.4869 1.60743,1.42865 3.64994,-0.24296 4.63342,1.66989 0.98348,1.91285 -2.56473,5.12155 -2.44593,7.27044 0.1188,2.14891 2.97378,5.01849 2.31651,7.05368 -0.65729,2.03519 -3.02038,-0.0143 -4.50675,1.54854 z",
	"m 0,0 c -1.56443,1.50809 -2.12016,2.46473 -4.2006,3.14438 -2.08042,0.67966 -3.46726,-1.31608 -5.66384,-1.68055 -2.19658,-0.36447 -3.72518,2.37602 -5.23492,0.79678 -1.50975,-1.57924 -2.12979,-3.60796 -3.03127,-5.52163 -0.90148,-1.91367 -2.63688,-1.24025 -2.36471,-3.36832 0.27218,-2.12808 1.65957,-4.63604 2.68336,-6.46074 1.02379,-1.82469 0.7809,-5.1596 2.57971,-6.39225 1.79881,-1.23265 4.9418,0.88074 6.99592,0.38209 2.05412,-0.49866 1.8629,-2.76399 4.03571,-2.08593 2.1728,0.67807 2.18347,3.15114 3.74566,4.62981 1.5622,1.47866 3.16531,0.4639 4.11079,2.43625 0.94548,1.97235 -1.48818,4.39211 -1.67347,6.5347 -0.1853,2.14259 2.48874,4.50888 1.33492,6.38533 -1.15381,1.87644 -1.75284,-0.30801 -3.31726,1.20008 z",
]
