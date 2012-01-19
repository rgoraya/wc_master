//script that draws the data
var paper; //so can draw in other methods
window.onload = function(){
	paper = new Raphael(document.getElementById('canvas_container'), document.getElementById("canvas_container").offsetWidth, document.getElementById("canvas_container").offsetHeight) //graphics context
  drawNodes() //call draw on the nodes
}


function drawNodes() //outside of onload so that we can redraw
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






