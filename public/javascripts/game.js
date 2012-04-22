/// THIS FILE CONTAINS THE JAVASCRIPT FOR THE GAME, OVERWRITING causemap_rjs AND mapvizualization_index WHERE APPROPRIATE

/*** 
 *** GLOBAL VARIABLES 
 ***/
var startBox; //the box where our islands start

var game_running = false;
var now_building = null; //the thing we're dragging
var edge_count = 1+currEdges['keys'].length //edge number we're making (initialize based on number of existing edges...)
var selector_canvases_drawn = []; //canvases we've drawn before
var all_ants = []; //all the ants (for tracking)
var active_ants = []; //the ants that we're animating
//var ant_nodes = [] //for the d3 animation version; the DOM nodes for the ants
var first_edge = true //if the (next) edge the first edge built?

//timer constants
var DEPLOY_TIME = 1
var SPAWN_TIME = 4
var PACE_TIME = 120
var HESITATE_TIME = 20
if(continuous){ //currently sort of fast, can slow down as we test
	DEPLOY_TIME = 100 
	SPAWN_TIME = 15
	PACE_TIME = 330
	HESITATE_TIME = 200 //should be 1/2 or 2/3 pace?
}

/***
 *** PLAY SOUNDS
 ***/

var SOUNDS = false; //toggle sound

function html5_audio(){
  var a = document.createElement('audio');
  return !!(a.canPlayType && a.canPlayType('audio/mpeg;').replace(/no/, ''));
}

function get_random_int(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

var play_html5_audio = false;
if(html5_audio()) play_html5_audio = true;

var snd; 

function play_sound(url){
	if(SOUNDS){
	  if(get_random_int(0, 10) > 8){
	    if(play_html5_audio){
	      snd = new Audio(url);
	      snd.load();
	      snd.play();      
	    }else{
	      $("#sound").remove();
	      var sound = $("<embed id='sound' type='audio/mpeg' />");
	      sound.attr('src', url);
	      sound.attr('loop', false);
	      sound.attr('hidden', true);
	      sound.attr('autostart', true);
	      $('body').append(sound);
	    }                 
	  }
	}
}


/***
 *** CLASS DEFINITIONS
 ***/

/*** ISLANDS ***/
function Island(n,opt_degree){
	this.n = n
	this.degree = opt_degree //how many edges we WANT to have coming out of us...
	this.bridges = []
	this.node = currNodes[this.n]
	this.icon = nodeIcons[this.n] //try to define, though will likely get null
	this.ants = []
	this.settled = []

	//do we want two timers, or will just 1 do? (depends on whether we want to deploy immediately after spawn...)
	this.spawn_timer = 0 
	this.spawn_count = 0
	this.deploy_timer = 0
	this.activated = false
	this.emptied = false
	this.deploy_lock = [false,false,-1]
}
Island.prototype.tick = function(){
	if(this.activated){
		if(!this.emptied && this.spawn_timer >= SPAWN_TIME){
			if(this.spawn_count < this.degree) //max spawning limit?
				this.spawnAnt()
			else
				this.emptied = true
			this.spawn_timer = 0
		}
		this.spawn_timer += 1

		if(this.deploy_timer > DEPLOY_TIME){
			if(this.ants.length > 0 && this.bridges.length > 0){ //only deploy if we actually have ants and bridges to send them on
				if(continuous)
					this.deployOneAnt()
				else
					this.deployAnts()
				this.deploy_timer = 0 //reset after we have deployed
			}
		}
		this.deploy_timer += 1
	}
}
Island.prototype.activate = function(){
	this.activated = true
	this.icon[2].show();//insertAfter(this.icon[0]) //hard-code move "house" after "island" to show
}
Island.prototype.spawnAnt = function(){
	var ant = new Ant(all_ants.length, [], this.n); //create a new ant on this island
	all_ants.push(ant)
	active_ants.push(ant)
	this.spawn_count += 1
}
Island.prototype.deployOneAnt = function(){ //deploy a single ant along an edge
	// console.log('deploying ants from',this)

	// this.deploy_lock[0] = true; //peterson's lock
	// this.deploy_lock[2] = 1;
	// while(this.deploy_lock[1] && this.deploy_lock[2] == 1){/*busy wait*/}
	
	var ant = this.ants.shift() //first waiting person
	
	var edge = currEdges[this.bridges[0]]
	// console.log('checking',edge.a.id,edge.b.id,(edge.reltype ? 1 : -1))
	ant.stat = ant.ON_PATH
	ant.path = this.bridges[0] //set them on the bridge!
	//console.log('error around here [',this.bridges.toString(), ']')
	ant.pathlen = edgeIcons[ant.path][0].getTotalLength()
	ant.prog = 0
	//figure out if we're moving the reverse of the path or not--if our island is the b item on the path we're taking
	ant.reverse = (ant.island == edge.b.id)
	// console.log(this.n,'starting on new path',this.path,'from', this.island, this.plan, this.reverse)
		
	//cycle the bridges for next launch
	this.bridges = this.bridges.slice(1).concat(this.bridges.slice(0,1))

	// this.deploy_lock[0] = false;

}
Island.prototype.deployAnts = function(){ //deploy ants along available edge
	// console.log('deploying ants from',this)

	//on "deploy" stage, go through the bridges, and send 1 ant down each
	for(var i=0, len=this.bridges.length; i<len; i++){ //go through the bridges
		if(this.ants.length > 0){
			var ant = this.ants.shift() //first waiting person
			// console.log('deploying',ant, this.ants.length, 'left')

			var edge = currEdges[this.bridges[i]]
			// console.log('checking',edge.a.id,edge.b.id,(edge.reltype ? 1 : -1))
			ant.stat = ant.ON_PATH
			ant.path = this.bridges[i] //set them on the bridge!
			ant.pathlen = edgeIcons[ant.path][0].getTotalLength()
			ant.prog = 0
			//figure out if we're moving the reverse of the path or not--if our island is the b item on the path we're taking
			ant.reverse = (ant.island == edge.b.id)
			// console.log(this.n,'starting on new path',this.path,'from', this.island, this.plan, this.reverse)

		}
		else{
			this.bridges = this.bridges.slice(i).concat(this.bridges.slice(0,i))
			//this.bridges.push(this.bridges.splice(0,i))	//cycle the bridge list for when we have more ants
			break;
		}
	}
}
Island.prototype.addAnt = function(ant,journeyed){
	if(!this.activated) //we're ready to go now that we've been reached!
		this.activate()
	if(journeyed){ //if we got here after a trip, settle down
		this.settled.push(ant)
		ant.stat = ant.ARRIVED
		ant.prog = 0
	}
	else{ //otherwise wait for orders
		this.ants.push(ant)
		ant.stat = ant.WAITING
		ant.prog = 0
	}
	//anything else that needs to be done?
}
Island.prototype.updateEdges = function(){
	// this.deploy_lock[1] = true; //peterson's lock
	// this.deploy_lock[2] = 0;
	// while(this.deploy_lock[0] && this.deploy_lock[2] == 0){/*busy wait*/}

	var old_bridges = this.bridges
	// console.log('old_bridges [',old_bridges.toString(), ']')

	this.bridges = [] //just refreshes the bridges; probably faster and easier for the amount of times we need to do it
	for(var i=0, len=currEdges['keys'].length; i<len; i++){
		if(currEdges[currEdges['keys'][i]].a == this.node || currEdges[currEdges['keys'][i]].b == this.node){
			this.bridges.push(currEdges[currEdges['keys'][i]].id)
			// console.log("adding",currEdges[currEdges['keys'][i]].id,"to bridges for",this,this.n)
		}
	}

	// console.log('before cycle [',this.bridges.toString(), ']')
	if(old_bridges.length > 0){
		var cycle = this.bridges.indexOf(old_bridges.slice(-1)[0]) //old last guy
		if(cycle < 0)
			cycle = this.bridges.indexOf(old_bridges[0])
		this.bridges = this.bridges.slice(cycle+1).concat(this.bridges.slice(0,cycle+1))
	}

	// this.deploy_lock[1] = false
}
Island.prototype.updatePos = function(dx,dy){ //moves the island (and all its ants) by [dx,dy]
	for(var i=0; i<this.ants.length; i++){
		//hard-moving because we don't want to add transforms to the ants
		this.ants[i].pos = {x:this.ants[i].pos.x+dx, y:this.ants[i].pos.y+dy}
		this.ants[i].icon.attr({'cx':this.ants[i].pos.x, 'cy':this.ants[i].pos.y})
	}
	for(var i=0; i<this.settled.length; i++){
		//hard-moving because we don't want to add transforms to the ants
		// var ant = this.settled[i]
		this.settled[i].pos = {x:this.settled[i].pos.x+dx, y:this.settled[i].pos.y+dy}
		this.settled[i].icon.attr({'cx':this.settled[i].pos.x, 'cy':this.settled[i].pos.y})
	}
}
Island.prototype.reset = function(){
	this.updateEdges() //reset the edges
	this.ants = []
	this.settled = []
	this.spawn_timer = 0 
	this.spawn_count = 0
	this.deploy_timer = 0
	this.activated = false
	this.emptied = false
	this.icon[2].hide();//insertBefore(this.icon[0]) //hard-code move "house" before "island" to hide (for next run)
}

//initialize the islands by adding icons, qtips, bridges, etc
function initIslands(){
	for(i in islands){
    islands[i].icon = nodeIcons[islands[i].n]; //add icons once they are drawn
		$([islands[i].icon[2].node]).data('island',i) //store the island in the node, so we can look up stuff about it in jquery
		$([islands[i].icon[2].node]).qtip(get_house_qtip(islands[i]))

		islands[i].updateEdges()
  }
  // console.log('initialized', islands);
}

/*** ANTS (Causlings) ***/
function Ant(n,plan,island){
	this.n = n
	this.plan = plan
	this.stat = 0
	this.path = -1
	this.pathlen = 0
	this.prog = 0
	this.reverse = false
	this.island = island
	islands[island].addAnt(this,false)
	this.pos = {x:currNodes[island].x, y:currNodes[island].y}
	this.icon = paper.circle(this.pos.x, this.pos.y,3)
		.attr({'fill':'#0f0'})
	// ant_nodes.push(this.icon.node) //for the d3 version
}
Ant.prototype.WAITING = 0;
Ant.prototype.ON_PATH = 1;
Ant.prototype.HESITATING = 2;
Ant.prototype.GETTING_LOST = 3;
Ant.prototype.SWIMMING = 4;
Ant.prototype.ARRIVED = 5;
Ant.prototype.GOING_HOME = 6;
Ant.prototype.DANCING = 7;
Ant.prototype.SETTLED = 8;
Ant.prototype.DEAD = 9;
Ant.prototype.DONE = 10;
Ant.prototype.tick = function(){
	if(this.stat == this.ARRIVED){
		this.arrive()
	}
	else if(this.stat == this.WAITING){ //waiting for a path...
		this.pace()
	}
	else if(this.stat == this.ON_PATH){
		this.walkPath()
	}
	else if(this.stat == this.HESITATING){
		this.hesitate()
	}
	else if(this.stat == this.GETTING_LOST){
		this.getLost()
	}
	else if(this.stat == this.SWIMMING){
		this.goSwimming()
	}
	else if(this.stat == this.DANCING){
		this.victoryDance()
	}
	else if(this.stat == this.GOING_HOME){
		this.settleDown()
	}
}
Ant.prototype.walkPath = function(){
	this.prog += 10; //take a step (sizable)
	if(this.prog < this.pathlen){ //if we're still on the path, take a step
		try{
			if(this.reverse)
				this.pos = edgeIcons[this.path][0].getPointAtLength(this.pathlen - this.prog);
			else
				this.pos = edgeIcons[this.path][0].getPointAtLength(this.prog);
		}
		catch(err){ //this should include deleting and swapping the edge
			this.stat = this.GETTING_LOST
			this.prog = 0
			this.icon.attr({'fill':'#A63E3E'})
			return;
		}
	}

	if(this.prog*3 > this.pathlen){ //if more than 1/4 way down the path, check for validity
		var validity = validPath(currEdges[this.path]);
		if(validity <= 0){ //always hesitate before dying on bad paths
			this.stat = this.HESITATING
			this.pathlen = [this.prog, this.pathlen]; //store the progress inside the pathlen
			this.prog = 0
			this.icon.attr({'fill':'#FFFF00'})
			return;
		}
		else if(validity < 0){
			this.stat = this.GETTING_LOST
			this.prog = 0
			this.icon.attr({'fill':'#A63E3E'})
			return;
		}
	}
	if(this.prog > this.pathlen){ //check if we're done
		if(this.reverse)
			this.island = currEdges[this.path].a.id;
		else
			this.island = currEdges[this.path].b.id;
		islands[this.island].addAnt(this,true) //set our new island (and we came from a journey). That will set our status
	}
}
Ant.prototype.hesitate = function(){
	if(validPath(currEdges[this.path]) > 0){ //if now a valid path, then just mark as good
		this.stat = this.ON_PATH
		this.prog = this.pathlen[0]
		this.pathlen = this.pathlen[1]
		this.icon.attr({'fill':'#0f0'})
		return;
	}

	this.prog += 1;
	if(this.prog > HESITATE_TIME){
		this.stat = this.GETTING_LOST
		this.prog = 0
		this.icon.attr({'fill':'#A63E3E'})
		return;
	}
	if(this.prog%8 == 0){ //step back
		this.pathlen[0] -= 2
	}
	else if(this.prog%4 == 0) //step forward
		this.pathlen[0] += 2

	try{ //try and take a step as we waver
		if(this.reverse)
			this.pos = edgeIcons[this.path][0].getPointAtLength(this.pathlen[1] - this.pathlen[0]);
		else
			this.pos = edgeIcons[this.path][0].getPointAtLength(this.pathlen[0]);
	}
	catch(err){ //this should include deleting and swapping the edge
		this.stat = this.GETTING_LOST
		this.prog = 0
		this.icon.attr({'fill':'#A63E3E'})
		return;
	}
}
Ant.prototype.getLost = function(){
	this.prog += 1
	if(this.prog%3==0){
		this.randomWalk(4)
		this.icon.attr({'opacity':1-(this.prog/100)})
	}	
	else if(this.prog > 60){
		this.stat = this.DEAD
		this.prog = 0
		this.icon.attr({'opacity':0.6})
		this.icon.toBack()
    play_sound("/sounds/incorrect.wav");
		return;
	}
}
Ant.prototype.randomWalk = function(step){
	this.pos = {x:this.pos.x+(Math.random()*step*2-step), y:this.pos.y+(Math.random()*step*2-step)}
}
Ant.prototype.pace = function(){
	this.prog += 1
	//short delay
	if(this.prog == 5)
		this.plan = Math.random()*360 //initial spot on the circle stored in plan
	else if(this.prog >= PACE_TIME) { //give up threshold
		this.stat = this.SWIMMING
		this.prog = 0
		this.icon.attr({'fill':'#A63E3E'})
		return;
	}
	else if(this.prog > 5 && this.prog%15 == 0){ //circle
		this.pos = {x:islands[this.island].node.x+20*Math.cos(this.prog/150+this.plan), y:islands[this.island].node.y+20*Math.sin(this.prog/150+this.plan)} //get a trajectory and assign it to plan
		this.icon.attr({'cx':this.pos.x, 'cy':this.pos.y})
	}

	// if(this.prog%PACE_TIME <= PACE_TIME/4 || this.prog%PACE_TIME > 3*PACE_TIME/4){
	// 	this.pos.x += -1 //pace left
	// 	this.icon.attr({'cx':this.pos.x, 'cy':this.pos.y})
	// }
	// else{
	// 	this.pos.x += 1 //pace right
	// 	this.icon.attr({'cx':this.pos.x, 'cy':this.pos.y})
	// }
}
Ant.prototype.goSwimming = function(){
	this.prog += 1
	if(this.prog == 1){
		// var angle = Math.random()*360
		// this.plan = {x:Math.cos(angle),y:Math.sin(angle)} //get a trajectory and assign it to plan		
		var dx = this.pos.x-islands[this.island].node.x
		var dy = this.pos.y-islands[this.island].node.y
		var dist = Math.sqrt(dx*dx+dy*dy)
		this.plan = {x:dx/dist, y:dy/dist }
		islands[this.island].ants.splice(islands[this.island].ants.indexOf(this),1) //remove from island's list
	}
	if(this.prog < 10){
		this.pos = {x:this.pos.x+(.8+Math.random()*.6)*this.plan.x, y:this.pos.y+(.8+Math.random()*.6)*this.plan.y}
		this.icon.attr({'cx':this.pos.x, 'cy':this.pos.y})
	}
	else{ //we're dead
		this.stat = this.DEAD
		this.prog = 0
		this.icon.attr({'opacity':0.6})
		this.icon.toBack()
    play_sound("/sounds/incorrect.wav")
		return;
	}
}
Ant.prototype.arrive = function(){
	this.stat = this.DANCING //start dancing
	this.prog = 0
	this.icon.attr({'fill':'#3CA03C'});
  play_sound("/sounds/correct.wav")
}
Ant.prototype.victoryDance = function(){
	this.prog += 1
	if(this.prog > 25){
		this.stat = this.GOING_HOME //settle down
		this.prog = 0
		return;
	}
	else if(this.prog%20 < 10){
		this.pos = {x:this.pos.x, y:this.pos.y-0.3} //bounce up
		this.icon.attr({'cx':this.pos.x, 'cy':this.pos.y})
	}
	else if(this.prog%20 < 20){
		this.pos = {x:this.pos.x, y:this.pos.y+0.3} //bounce down
		this.icon.attr({'cx':this.pos.x, 'cy':this.pos.y})
	}
}
Ant.prototype.settleDown = function(){
	this.prog += 1
	if(this.prog == 1)
		this.icon.insertBefore(islands[this.island].icon[2]) //move the ant behind the house (currently #2)
	if(this.prog <= 4){
		var vx = .25*(currNodes[this.island].x - this.pos.x) //quarter of the distance to the center
		var vy = .25*(currNodes[this.island].y - this.pos.y)
		this.pos = {x:this.pos.x+vx, y:this.pos.y+vy}
		this.icon.attr({'cx':this.pos.x, 'cy':this.pos.y})
	}
	else{
		this.stat = this.SETTLED //stop moving for future ticks
		this.prog = 0
		this.icon.insertBefore(islands[this.island].icon[3]) //move behind the coast to hide entirely
		this.icon.hide() //also just outright hide :p
		return;
		//console.log(this.n, 'settled down at', currNodes[this.island].name)
	}
}

//convenience method to check validity of an edge. Returns 1 if valid, 0 if bad relationship, or -1 if totally invalid
function validPath(edge){
	var reltype = (edge.reltype ? 1 : -1)
	try{
		if(yes[edge.a.id][edge.b.id][reltype] > 0) //check if it is a valid bridge
			return 1;
	}catch(err){} //if we couldn't read the edge, then we know it wasn't valid
	try{
		if(yes[edge.a.id][edge.b.id][-1*reltype] > 0) //check if swap is a valid bridge
			return 0;
	}catch(err){}
	try{
		if(yes[edge.b.id][edge.a.id][reltype] > 0) //check if reverse is a valid bridge
			return 0;
	}catch(err){}
	try{
		if(yes[edge.b.id][edge.a.id][-1*reltype] > 0) //check if reverse swap is a valid bridge
			return 0;
	}catch(err){}
	
	return -1; //none of the options were valid
}


/***
 *** GAME INTERACTION METHODS
 ***/

//starts the game!
function beginGame(){
	clearTheBoard()
	startAnimation(paper)
}

//removes all the ants, resets the islands
function clearTheBoard(){
	for(i in islands){ //reset the islands
		islands[i].reset()
	}

	islands[HOME].activate() //open the home island
	islands[HOME].spawn_timer = SPAWN_TIME //first island begins spawning and deploying
	islands[HOME].deploy_timer = DEPLOY_TIME-5

	if(typeof all_ants !== 'undefined') {
		console.log("clearing ants for subsequent run")
		for(var i=0, len=all_ants.length; i<len; i++)
			all_ants[i].icon.remove()
	}
	//clear out the ants for next time
	var all_ants = [];
	var active_ants = [];
}

//starts animating!
function startAnimation(paper) {
	console.log('starting animation')

	//block out all the other interactions so that the user doesn't break things
	if(!continuous)
		var block = paper.rect(0,0,paper.width,paper.height).attr({'opacity':0, 'fill-opacity':0,'stroke-width':0})

	// var d3nodes = d3.selectAll(ant_nodes)
	var count = 0
	animator = setInterval(function() {

		//raphael implementation
		for(key in islands){
			islands[key].tick() //tick the islands, who spawn and deploy their ants
		}

		inactive = []
		for(var i=0, len=active_ants.length; i<len; i++){
			active_ants[i].tick() //do what they do!
			active_ants[i].icon.attr({'cx':active_ants[i].pos.x, 'cy':active_ants[i].pos.y})
			// active_ants[i].icon.animate({'cx':active_ants[i].pos.x, 'cy':active_ants[i].pos.y},10) //can be replaced with d3
			if(active_ants[i].stat == active_ants[i].DONE || 
				 active_ants[i].stat == active_ants[i].SETTLED || 
				 active_ants[i].stat == active_ants[i].DEAD){ //if we're done, we shouldn't be in this list!
				inactive.push(active_ants[i]) //prepare to drop anyone who is done
			}
		}
		for(var i=0, len=inactive.length; i<len; i++){
			active_ants.splice(active_ants.indexOf(inactive[i]),1)
		}

		//d3 implementation, for potentially smoother animation? Doesn't seem to help much, as we're doing complex calculations.
		// http://stackoverflow.com/questions/8239235/smoothly-animate-attribute-changes-to-3000-raphael-objects-at-once
		// http://jsfiddle.net/ekMd6/
		// d3nodes
		// 	.transition()
		// 	.attr('cx', function(d,i){return ants[i].pos.x;})
		// 	.attr('cy', function(d,i){return ants[i].pos.y;})
		// 	.duration(1)

		count += 1;
		var done = active_ants.length == 0
		if(done){ //only check island status if we don't have anyone else moving, to save time
			for(i in islands){ if(islands[i].activated && !islands[i].emptied){ done = false;break; }}
		}

		// console.log('step',count, done)
		if(done){
		// if(done || count > 100){
			console.log('done animating at count',count)
			clearInterval(animator);

			//show the score after animation is done (or before?)
			var score_str = getScoreBoard();
			$('#score_content').html(score_str);
			$('#score_notice').toggle(true);

			if(typeof block !== 'undefined')
				block.remove()

			console.log('#actives',active_ants.length)
      game_running = false;
		}
	}, 30);

}


/***
 *** DRAWING CODE
 ***/

//sets up initial boxes and stuff for the game
function drawInitGame(paper){
  var startBoxSize = [120,paper_size.height];
  var startBoxTopLeft = [paper_size.width-122,0];

	startBox = paper.rect(startBoxTopLeft[0],startBoxTopLeft[1],startBoxSize[0],startBoxSize[1]).attr({'stroke': '#000000', 'stroke-width':1});
  paper.rect(startBoxTopLeft[0],startBoxTopLeft[1],startBoxSize[0],30).attr({'fill':'#FFFFFF','fill-opacity':1});
	paper.text(paper_size.width-115,15,'Concepts').attr({
		'text-anchor':'start', 
		'font':'lucida grande', 'font-family':'sans-serif',
		'font-size':24, 'font-weight':'bold',
		'fill':'#BEBEBE',
    
	})
	paper.rect(startBoxTopLeft[0],30,startBoxSize[0],15)
    .attr({'fill':'#000000','stroke':'#000000'})
    .mouseover(function(){this.attr({'fill':'#BEBEBE'})})
    .mouseout(function(){this.attr({'fill':'#000000'})})
    .click(function(){
      for (var i in nodeIcons) if(paper_size.width-currNodes[i].x<startBoxSize[0]) nodeIcons[i].transform("...t0,-30"); //go up
    });
	paper.rect(startBoxTopLeft[0],paper_size.height-15,startBoxSize[0],15)
    .attr({'fill':'#000000', 'stroke':'#000000'})
    .mouseover(function(){this.attr({'fill':'#BEBEBE'})})
    .mouseout(function(){this.attr({'fill':'#000000'})})
    .click(function(){
      for (var i in nodeIcons) if(paper_size.width-currNodes[i].x<startBoxSize[0]) nodeIcons[i].transform("...t0,30"); //go down
    });
}

//details on drawing/laying out a node
function drawNode(node, paper){
		//var island_style = Math.floor(Math.random()*4)
		var island_style = node.id%ISLAND_PATHS.length

		var island = paper.image("/images/game/island_center_"+Math.ceil(Math.random()*5)+".png",node.x-12.5,node.y-12.5,25,25);

		var coast = paper.path(ISLAND_PATHS[island_style]).attr({
			fill: '#3E8653', 'stroke': '#3E8653', 'stroke-width': 1,
		}).insertBefore(island);
		var coast_shadow = paper.path(ISLAND_PATHS[island_style]).attr({
			fill: '#BDBDBD', 'stroke-width':0, 'stroke-opacity':0
		}).insertBefore(coast);

		var bb = coast.getBBox();
		var trans_string = "t"+(node.x-(bb.x+bb.width/2))+","+(node.y-(bb.y+bb.height/2))
		coast.transform(trans_string)
		coast_shadow.transform(trans_string+"...t0,2.5")

		var content = node.name.toUpperCase();
		// _textWrapp(content,80)
		if(content.length > 15)
			content = content.substring(0,15)+"..."
		var txt = paper.text(node.x, node.y+30, content).attr({
			'fill': '#fff', 'font-size':10.5, 'font-weight':'bold',
		});

		var house_path = 'M'+node.x+','+node.y+'m0,-7 l6,6 l0,7 l-12,0 l0,-7 z'
		var house = paper.path(house_path).attr({
			gradient: '0-#71695e-#52483a','stroke-width':0,'stroke-opacity':0
		})
		.hide();// .insertBefore(island) //hide the house for now

		var icon = paper.set()
		.push(island,txt,house)
		.mouseover(function() {this.node.style.cursor='move';})//hoverNode(node)})
		.mousedown(function(e) {now_dragging = {icon:icon, node:node};})
		.drag(dragmove, dragstart, dragend) //enable dragging!

		icon.push(coast,coast_shadow)
		coast.mouseover(function() {this.node.style.cursor='crosshair';})
		.mousedown(function(e) {now_building = {start_node:node};})
		.undrag()
		coast.drag(buildmove, buildstart, buildend)

		$([island.node,txt.node]).qtip(get_node_qtip(node)); //if we want a tooltip
		$(coast.node).qtip({
			content:{text: 'Drag to create a path'},
			position:{target: 'mouse',adjust: {y:4}},
			style:{classes: 'ui-tooltip-light ui-tooltip-shadow'}
		});

		return icon;  
}

//details on drawing/laying out an edge (a single line/relationship)
function drawEdge(edge, paper){

		var a = edge.a;
		var b = edge.b;

		var curve = getPath(edge) //get the curve's path		
		var e = paper.path(curve).attr({'stroke-width':5}).toBack()
		
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

		var center = getPathCenter(curve,-2)
		var selector = paper.circle(center.x,center.y,10).attr({'fill':'#00ff00', 'opacity':0.0, 'stroke-width':0})
		$(selector.node).qtip(get_edge_qtip(edge))
		$(e.node).qtip(get_edge_qtip_small(edge))

		var icon = paper.set() //for storing pieces of the line as needed
		.push(e, arrow[0], arrow[1], dots, selector)

		return icon;
}

//draws the edge-editing box for a given edge and canvas_id
function drawEdgeSelectors(edge, canvas_id){
	// console.log('selector_canvas_'+canvas_id)
	var canvas = new Raphael('selector_canvas_'+canvas_id, 40, 45) //the canvas to draw on

	edge.a.x = parseInt(edge.a.x) //convert from json strings to ints, if necessary
	edge.a.y = parseInt(edge.a.y)
	edge.b.x = parseInt(edge.b.x)
	edge.b.y = parseInt(edge.b.y)
	var edge_incr = parseInt(edge.reltype)&INCREASES //is the edge an increaser?

	var curve = getPath(edge) //get the curve's path		
	var midPoint = getPathCenter(curve)//, ARROW_LENGTH/2); //midpoint offset by arrow-length
	if(edge.a.x <= edge.b.x && edge.b.y <= edge.a.y){ //sometimes we need to flip the alpha, seems to be covered by this
		if(!(edge.b.y == edge.a.y && midPoint.alpha > 360)){ //handle special case, if b.y == a.y, seems to work 
			midPoint.alpha = midPoint.alpha+180 % 360 //flip 180 degrees so pointed in right direction
	}}

	midPoint.x = 15 //force our 'midpoint'
	midPoint.y = 12
	
	//draw alternative arrow
	var arrowPath = getArrowPath(midPoint, 0)
	var arrow = canvas.path(arrowPath) //draw the arrowhead
		.attr({stroke:'none'})
		.transform('s1.2')
		.transform("...r"+(midPoint.alpha)) //rotate and flip
	if(!edge_incr){ //if we're not increasing, make this the 'increase' option
		arrow.attr({fill:EDGE_COLORS['increases']})
	}
	else{ //if decreases
		arrow.attr({fill:EDGE_COLORS['decreases']});	
	}
	var arrowSymbolPath = getArrowSymbolPath(midPoint, (edge_incr ? 0 : 1))
	var arrowSymbol = canvas.path(arrowSymbolPath) //draw the symbol on the arrow
		.attr({fill:'#ffffff', stroke:'none'})
		.transform('...r'+midPoint.alpha+'t-3,0') //apply offset after rotation
	var swapSelector = canvas.circle(15,10,12).attr({'fill':'#00ff00', 'opacity':0.0, 'stroke-width':0})
		.mouseover(function() {
			this.node.style.cursor='pointer';
			this.g = arrow.glow({width:3})
		})
		.mouseout(function() { this.g.remove() })
		.click(function() {swapEdge(edge, (edge_incr ? 0 : 1));})

	//draw delete X
	var deletePath = 'M -1 1 L 1 -1 M -1 -1 L 1 1'
	var deleteSymbol = canvas.path(deletePath)
		.attr({'stroke-width':3, 'stroke':'#d24648', 'stroke-linecap':'round'})
		.transform('...s5 T15,35')
	var deleteSelector = canvas.circle(15,35,10).attr({'fill':'#00ff00', 'opacity':0.0, 'stroke-width':0})
		.mouseover(function() {
			this.node.style.cursor='pointer';
			this.g = deleteSymbol.glow({width:3})
		})
		.mouseout(function() { this.g.remove() })
		.click(function() {destroyEdge(edge);})
}


/***
 *** MOUSE INTERACTION
 ***/

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
				oldSymbol = edgeIcons[edge.id].splice(1,4) //remove the symbol, since we're not moving it
				oldSymbol.remove()
			}
		}
	}

	var data = ["dragStart",["node.id",now_dragging.node.id,"node.name",now_dragging.node.name,"node.x",now_dragging.node.x,"node.y",now_dragging.node.y,"node.url",now_dragging.node.url,"node.h",now_dragging.node.h].join(":")].join("|");
	//console.log(data);
	sendLog(data);
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

		//tell the island to update as well
		islands[now_dragging.node.id].updatePos(trans_x,trans_y)
	}
};
var dragend = function (x,y,event) 
{
	for(var i=0, len=dragged_edges.length; i<len; i++) //redraw the icons on the edges
	{
		var curve = getPath(dragged_edges[i]) //get new curve
		var arrow = drawArrow(dragged_edges[i],curve,paper) //just go ahead and redraw the arrow and dots
		edgeIcons[dragged_edges[i].id].push(arrow[0],arrow[1])
		arrow.insertAfter(edgeIcons[dragged_edges[i].id][0])
		var dots = drawDots(dragged_edges[i],curve,paper)
		edgeIcons[dragged_edges[i].id].push(dots)
		dots.insertAfter(edgeIcons[dragged_edges[i].id][0])
		var center = getPathCenter(curve,-2)
		var selector = paper.circle(center.x,center.y,10).attr({'fill':'#00ff00', 'opacity':0.0, 'stroke-width':0})
		edgeIcons[dragged_edges[i].id].push(selector)
		$(selector.node).qtip(get_edge_qtip(dragged_edges[i]))
		// $([arrow[0].node,arrow[1].node]).qtip(get_edge_qtip(dragged_edges[i])); //add pop-up handler...
	}

	var data = ["dragEnd",["node.id",now_dragging.node.id,"node.name",now_dragging.node.name,"node.x",now_dragging.node.x,"node.y",now_dragging.node.y,"node.url",now_dragging.node.url,"node.h",now_dragging.node.h].join(":")].join("|");
	//console.log(data);
	sendLog(data);

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

	var data = ["buildStart",["start_node.id",now_building.start_node.id,"start_node.name",now_building.start_node.name,"edge.reltype",now_building.edge.reltype].join(":")].join("|");
	//console.log(data);
	sendLog(data);

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
			var bb = icon.getBBox() //compare to the bounding box of whole icon (circle is [4] atm)
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
			edge.id = edge_count
			//edge.id = currEdges['keys'].length+1; //give id that's just a count (1...n) //assign count and then increment
			edge.name = edge.a.name+(edge.reltype&INCREASES ? ' increases ' : ' decreases ')+edge.b.name
			var key = edge.id//edge.a.id+(edge.reltype&INCREASES ? 'i' : 'd')+edge.b.id

			//go through edges and see if we already exist
			var prev_id = -1
			for(var i=0, len=currEdges['keys'].length; i<len; i++){
				if(currEdges[currEdges['keys'][i]].name == edge.name){ //has same name should mean same edge, since standardized
					prev_id = currEdges['keys'][i]
					break;
				}
			}

			if(prev_id >= 0){ //if edge already exists
				edge.id = prev_id; //replace the old id
				edgeIcons[edge.id].remove() //get rid of the old icon
			}
			else{
				edge.id = edge_count
				//edge.id = currEdges['keys'].length+1; //give id that's just a count (1...n)
				currEdges['keys'].push(key) //only push the key if this is a new edge (and so we need to add it to the list)

			}
			currEdges[key] = edge
			edge_count += 1

			//set up the icon
			now_building.icon.remove() //remove our building icon
			edgeIcons[edge.id] = drawEdge(edge, paper) //redraw with the correct edge associated
			// $(icon[0].node).qtip(get_edge_qtip_small(edge))
			// $(icon[3].node).qtip(get_edge_qtip(edge)); //add handlers

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
			
			//if this is the first edge we've made in continous mode, start the game!!
			if(first_edge && continuous){
				//should probably alert the user with a pop-up
				first_edge = false;
				beginGame()
			}

			islands[edge.a.id].updateEdges() //update the edges for the islands -- AFTER we've cleared the board and launched the game
			islands[edge.b.id].updateEdges()
			islands[edge.a.id].deploy_timer = DEPLOY_TIME
			islands[edge.b.id].deploy_timer = DEPLOY_TIME

		}
		else {
			now_building.icon.remove() //remove the icon, cause we didn't select anything
		}
	}

	var data = ["buildEnd",["edge.id",now_building.edge.id,"edge.name",now_building.edge.name,"edge.a",now_building.edge.a.id,"edge.b",now_building.edge.b.id,"edge.reltype",now_building.edge.reltype,"edge.expandable",now_building.edge.expandable,"edge.n", now_building.edge.n].join(":")].join("|");
	//console.log(data);
	sendLog(data);

	//reset variables
	now_building = null
};

function destroyEdge(edge) {

	var data = ["destroyEdge",["edge.id",edge.id,"edge.name",edge.name,"edge.a",edge.a.id,"edge.b",edge.b.id,"edge.reltype",edge.reltype,"edge.expandable",edge.expandable,"edge.n", edge.n].join(":")].join("|");
	//console.log(data);
	sendLog(data);

	var key = edge.id //edge.a.id+(parseInt(edge.reltype)&INCREASES ? 'i' : 'd')+edge.b.id //the key we should have constructed
	if(currEdges[key]){
		//remove edge from list
		for(var i=0, len=currEdges['keys'].length; i<len; i++){
			if(currEdges['keys'][i]==key){
				currEdges['keys'].splice(i,1)
				break
			}
		}
		delete currEdges[key]
		
		islands[edge.a.id].updateEdges() //update the edges for the islands
		islands[edge.b.id].updateEdges()
		
		edgeIcons[edge.id].remove() //remove icon

		//de-arc other edges
		var tounbend = [] //because could be more than 1
		for(var i=0, len=currEdges['keys'].length; i<len; i++){
			var e = currEdges[currEdges['keys'][i]]
			if( (e.a == edge.a && e.b == edge.b) || (e.a == edge.b && e.b == edge.a) ) //find other edges with same terminals
				tounbend.push(e)
		}
		for(var i=1, len=tounbend.length; i<=len; i++){
			var e = tounbend[i-1], oldn = e.n
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
	else
		console.log('edge does not exist. PROBLEM.')

	$('.qtip.ui-tooltip').qtip('hide');	
}

function swapEdge(e, new_reltype){
	var idBefore = e.id;
	var reltypeBefore = e.reltype;

	var key = e.id //e.a.id+(parseInt(e.reltype)&INCREASES ? 'i' : 'd')+e.b.id //the key we should have constructed
	var edge = currEdges[key]
	edge.reltype = new_reltype
	edge.name = edge.a.name+(edge.reltype&INCREASES ? ' increases ' : ' decreases ')+edge.b.name

	//remove old edge&key from list
	for(var i=0, len=currEdges['keys'].length; i<len; i++){
		if(currEdges['keys'][i]==key){
			currEdges['keys'].splice(i,1)
			break
		}
	}
	delete currEdges[key]
	
	var newkey = edge.id //edge.a.id+(edge.reltype&INCREASES ? 'i' : 'd')+edge.b.id
	currEdges[newkey] = edge
	currEdges['keys'].push(newkey) //add to list with new key

	edgeIcons[edge.id].remove() //remove old icon
	edgeIcons[edge.id] = drawEdge(edge,paper)

	var data = ["swapEdge",["edge.id.before",idBefore,"edge.id.after",edge.id,"edge.reltype.before",reltypeBefore,"edge.reltype.after",edge.reltype,"edge.a",e.a.id,"edge.b",e.b.id,"edge.expandable",e.expandable,"edge.n",e.n].join(":")].join("|");
	//console.log(data);
	sendLog(data);


	$('.qtip.ui-tooltip').qtip('hide');	
}


/***
 *** QTIPS AND TEXT RENDERING
 ***/

//calculates the score based on current global variables; returns an html string displaying the score
function getScoreBoard(){
	var activated = 0
	var total_islands = 0
	for(i in islands){
		if(islands[i].activated)
			activated += 1
		total_islands += 1
	}

	var settled = 0
	var dead = 0
	var total_ants = all_ants.length;
	for(var i=0, len=all_ants.length; i<len; i++){
		if(all_ants[i].stat == all_ants[i].SETTLED)
			settled += 1
		else if(all_ants[i].stat == all_ants[i].DEAD)
			dead += 1
	}

	var rubric = 0
	for(var i=0, len=currEdges['keys'].length; i<len; i++){
		var edge = currEdges[currEdges['keys'][i]]
		try{
			if(yes[edge.a.id][edge.b.id][(edge.reltype ? 1 : -1)]){ //check if it is a valid edge
				rubric += yes[edge.a.id][edge.b.id][(edge.reltype ? 1 : -1)]
			}
			else{
				rubric += -0.5 //hard-code the penalty atm
			}
		}
		catch(err){ //has problem reading undefined directions; if we couldn't read the object, then it was wrong!
			rubric += -0.5
		}
	}

	//hard-code the layout here...
	var out = "<b><u>Game Results</u></b><br>"+
		"<table class='scoreboard'>"+
		"<tr><td class='item'>Islands visited:</td><td class='score'>"+activated+" ("+Math.round(100*activated/total_islands)+"%)</td></tr>"+
		"<tr><td class='item'>Causlings settled:</td><td class='score'>"+settled+" ("+Math.round(100*settled/total_ants)+"%)</td></tr>"+
		"<tr><td class='item'>Mortality rate:</td><td class='score'>"+Math.round(100*dead/total_ants)+"%</td></tr>"+
		"<tr><td class='item'>Final score:</td><td class='score'>"+rubric+" pts</td></tr>"+
		"</table>"

	return out;
}

//layout details for the node qtip
function get_node_qtip(node) {
	return {
		content:{
			text: '<div id="issue_qtip"><div class="formcontentdiv"><div class="heading">' + 
							node.name + '</div></div></div>'
		},
		position: {
			my: 'top-center',
			at: 'bottom-center',
			target: 'mouse',
			adjust:{y:4},
		},
		style: {
			classes: 'ui-tooltip-light ui-tooltip-shadow',
			tip: {
				//http://craigsworks.com/projects/qtip2/docs/plugins/tips/
				width:10,
				height:6,
			},
		},
	};
}
//layout details for the house qtip
function get_house_qtip() {
	return {
		content:{
			text: function(api){
				var island = islands[$(this).data('island')]
				return '<div class="house_descr"><b>'+island.settled.length+' Causlings</b> <br> have settled at concept <br>' 
								+ '<i>'+island.node.name+'</i>'
								+ '</div>';
			}
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
//layout details for the small edge qtip
function get_edge_qtip_small(edge) {
	return {
		content:{
			text: '<div class="edge_title">' + edge.name + '</div>'
		},
		position: {
			target: 'mouse',
			adjust: {y:4}
		},
		style: {
			classes: 'ui-tooltip-light ui-tooltip-shadow',
			width: 200,
		},
	};	
}
//layout details for the edge qtip
function get_edge_qtip(edge) {
	var canvas_id = Math.random()
	return {
		content:{
			text: "<div id='relation_qtip'><div class='selector_container'><div id='selector_canvas_"+canvas_id+"'></div></div>"+
			  		"<div class='descr_container'><div class='heading'>"+edge.name+"</div></div></div>"
			//currently not using ajax for faster load times (since we don't need to fetch from db, yet)
			// text: 'Loading...',//+edge.name+'...', //and what's sad is that this is only temporary...
			// ajax:{
			// 	url: 'game/edge_qtip',
			// 	type: 'GET',
			// 	data: {edge: edge},
			// }
		},
		position: {
			my: 'top left',
			at: 'center',
			adjust: {x:-15, y:3}
		},
		style: {
			classes: 'ui-tooltip-light ui-tooltip-shadow',
			tip: {
				//http://craigsworks.com/projects/qtip2/docs/plugins/tips/
				corner: true,
				mimic: 'center',
				width:25,
				height:10,
				offset:10,
			},
		},
		hide: {
			fixed: true,
		},
		events: {
			show: function(event, api) {
				if($.inArray(canvas_id, selector_canvases_drawn) < 0){
					drawEdgeSelectors(edge, canvas_id);
					selector_canvases_drawn.push(canvas_id)
				}
			}
		},
	};	
}


/***
 *** AJAX SETUP AND METHODS
 ***/

$(document).ready(function(){
	$("#score_notice .closebutton").click(function(){
		$("#score_notice").slideUp(100);
	});
	
	$("#run_button").click(function(){
		if (game_running === false) {
      beginGame();
      game_running = true;
    }
	});
});

function sendLog(info){
	//console.log(time_stamp);
	$.ajax({
		type:'POST',
		url:'/game/log',
		data:{'data':info, 'time_stamp':time_stamp}
	});
}


/***
 *** MISC METHODS AND CONSTANTS
 ***/
_textWrapp = function(t, width, max_length) {
	/**
	 * adapted from
	 * http://stackoverflow.com/questions/3142007/how-to-either-determine-svg-text-box-width-or-force-line-breaks-after-x-chara
	 * @param t a raphael text shape
	 * @param width - pixels to wrapp text width
	 * modify t text adding new lines characters for wrapping it to given width.
	 */
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
	"m -0,0 -7.088,1.492 -2.999,-5.582 -2.472,-5.198 -0.885,-5.659 2.414,-5.164 1.653,-5.178 3.623,-4.266 4.225,-5.049 6.387,-1.183 6.041,2.246 5.867,2.206 1.856,6.39 4.868,3.944 3.066,6.054 -1.885,6.437 -3.694,5.276 -3.636,5.463 -6.785,0.361 -5.698,-0.188 z",
	"m 0,0 -2.157,6.67 -6.13,-0.169 -5.553,-0.426 -5.177,-1.979 -3.174,-4.509 -3.55,-3.879 -1.84,-5.094 -2.207,-5.977 2.079,-5.931 4.793,-3.991 4.673,-3.865 6.256,1.516 5.654,-2.19 6.558,0.337 4.497,4.681 2.653,5.639 2.837,5.681 -2.96,5.869 -2.898,4.695 z",
	"m 0,0 -2.157,6.67 -6.13,-0.17 -5.553,-0.425 -5.176,-1.98 -3.174,-4.509 -3.551,-3.879 -1.84,-5.094 -2.207,-5.977 2.079,-5.93 4.793,-3.991 2.673,-3.865 6.257,1.515 5.653,-2.19 6.559,0.338 6.497,4.68 2.652,5.639 2.837,5.682 -2.96,5.868 -2.897,4.696 z",
	"m 0,0 2.821,-5.664 3.183,-3.811 4.273,-4.318 5.829,2.469 4.65,2.001 6.153,-1.063 4.062,3.888 2.887,5.67 3.617,5.686 -4.731,5.164 -0.815,6.23 -5.704,2.288 -4.633,2.976 -5.551,1.189 -5.97,0.845 -5.11,-3.277 -7.486,-2.388 4.021,-7.891 -0.179,-4.986 z",
	"m 0,0 6.677,1.676 4.793,2.496 5.587,3.535 -1.264,6.772 -1.043,5.41 2.565,6.291 -3.185,5.226 -5.352,4.393 -5.202,5.172 -6.593,-3.826 -6.812,0.587 -3.762,-5.531 -4.244,-4.23 -2.56,-5.623 -2.29,-6.149 2.291,-6.195 0.793,-8.516 9.325,2.434 5.259,-1.354 z"
]

