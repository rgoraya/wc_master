//script that draws the data
var paper; //so can draw in other methods
window.onload = function(){
	paper = new Raphael(document.getElementById('canvas_container'), 500, 500) //graphics context

  //set locations for the nodes; do it here so we can tweak based on display size??
  //draw nodes into evenly-spaced rows
  // num_cols = Math.ceil(Math.sqrt(nodes.length+1));
  // col_len = Math.floor(paper.width/num_cols);
  // num_rows = Math.ceil((nodes.length+1)/num_cols);
  // row_len = Math.floor(paper.height/num_rows);
  // for(var i=0; i<nodes.length; i++)
  // {
  //   nodes[i].x = (.5 + (i%num_cols))*col_len; //var row = Math.floor(i/num_cols);
  //   nodes[i].y = (.5 + Math.floor(i/num_cols))*row_len; //var col = i % num_cols;
  // }

  //initial arrange in circle, radius = 200, centered at 250,250
  for(var i=0; i<nodes.length; i++)
  {
    nodes[i].x = 250 + (200 * Math.cos(2*Math.PI*i/nodes.length));
    nodes[i].y = 250 + (200 * Math.sin(2*Math.PI*i/nodes.length));
  }
  
  drawNodes()

  /*****************
  ******************AFTER WE HAVE LOADED, DEFINE FUNCTIONS WE'LL NEED
  ******************/
}


function drawNodes()
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
    var a = nodes[edges[i].a]
    var b = nodes[edges[i].b]
    var e = paper.path("M"+a.x+","+a.y+"L"+b.x+","+b.y+"z").toBack().attr({
      stroke: '#bd55dd',
      'stroke-width': edges[i].weight
    })
    .data("name","Edge from "+a.name+" to "+ b.name)
    .click(function() { alert("You clicked on "+this.data("name"))})
    .mouseover(function() {this.node.style.cursor='pointer';})

  }  
}

function whichclick(item)
{
  alert("you clicked on"+item)
}

function eadesLayout()
{
  //ORGANIZE NODES (SPRING SYSTEM)
  //start with implementing kamada-kawai
  //the try fruchterman-reingold; can combine if needed (and have render time)
    //note that for very large graphs, this code should be moved server-side (we should probably get positions before we draw?)

  c1 = 2; c2 = 1; c3 = 1; c4 = 0.1;
  for(var m=0; m<100; m++)
  {
    for(var i=0; i<nodes.length; i++)
    {
      nodes[i].dx = 0; nodes[i].dy = 0;
      for(var j=0; j<nodes.length; j++)
      {
        if(i!=j)
        {
          dist = node_dist(nodes[i], nodes[j])
          nx = (nodes[j].x-nodes[i].x)/dist //normal vector
          ny = (nodes[j].y-nodes[i].y)/dist
          if(adjacency[i][j] == 1) //if connected according to adjacency matrix
          {
            f = c1*Math.log(dist/c2)/Math.LN10 //force
            if(i==0 && j==1)
              console.log("attract:"+f);
            nodes[i].dx += f*nx //move along attracting vector
            nodes[i].dy += f*ny
          }
          else
          {
            f = c3/Math.sqrt(dist)
            if(i==0 && j==1)
              console.log("repel:"+f)
            nodes[i].dx -= f*nx //move away from repelling vector
            nodes[i].dy -= f*ny
          }
        }
      }
    }
    console.log("Node 0 moved:"+nodes[0].dx+", "+nodes[0].dy)
    for(var i=0; i<nodes.length; i++)
    {
      nodes[i].x += c4*nodes[i].dx //move along vector
      nodes[i].y += c4*nodes[i].dy
    }
    //DRAW THE NODES TO DEBUG!!

    drawNodes();

  }
}








