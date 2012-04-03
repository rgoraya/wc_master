/* Functions and such for interacting on the index page (usually ajax-based) */

$(document).ready(function(){
	// $("#notice").html(notice_msg);
	//   if ($('#notice').html().trim()) {
	//   	$("#notice_container").show();
	//   	$("#notice_container").effect("bounce", { times:3 }, 200);
	//   }

	//   $("#spinner").css('left',$('#canvas_container').width()/2-32)
	//     .css('top',$('#canvas_container').height()/2-32)
	//     .toggle();
	// //console.log($("form.button_to"))
	//   $("form.button_to") //anything formed by the button_to tag apparently
	// 	.bind("ajax:beforeSend", function(e) {
	// 	  $("#spinner").toggle()
	// 	})
	// 	.bind("ajax:complete", function(e) {
	// 	  $("#spinner").toggle()
	// 	})

	$('#modal_container .btn_close').live('click', function(){
		$('#modal_container').toggle(false);
	});
	$('#modal_container .modal_linkout').live('click', function(){
    $('#modal_container').toggle(false);
		//should then execute the primarily bound function
	});

	$('#vis_cause_search_form, #vis_effect_search_form').submit(function() {
		show_progress_message('loading...') //show progress message
		//should also probably lock out the forms...
	});
	
});


// //show the details sidebar
// function show_details(data) {
//   $('#detail_fill').html(data.responseText);
//   $('#detail_container').toggle(true);
// }
// 
// function hide_details() {
//   $('#detail_container').toggle(false);	
// }

//show the modal window
function show_modal(data) { 
  $('#modal_fill').html(data.responseText);
  $('#modal_container').toggle(true);
};

function hide_modal() {
  $('#modal_container').toggle(false);	
  // $('#modal_fill').html('');
}

//put the modal window in the desired location (relative to parent of course)
//has positioning information that is based off of the css classes
function position_modal(click_x,click_y) {
  c_width = $('#canvas_container').width(); 
  c_height = $('#canvas_container').height(); 
  m_width = $('#modal_container').width();
  m_height = $('#modal_container').height();
  
  x = Math.min(Math.max(click_x-m_width/2,0),c_width-m_width);
  y = -1*c_height + click_y;

  above = click_y > c_height/2 //if we clicked below the equator, place modal above

  if(above) { //set the arrows and such
    y -= (5+15+m_height) //make room for arrow below
    $('#modal_container .up_pointer_arrow').toggle(false);
    $('#modal_container .down_pointer_arrow').toggle(true);
    $('#modal_container .down_pointer_arrow').css('margin-right',(m_width-10)-(click_x-x)); //set arrow's offset
  }
  else {
    y += 5
    $('#modal_container .up_pointer_arrow').toggle(true);
    $('#modal_container .down_pointer_arrow').toggle(false);
    $('#modal_container .up_pointer_arrow').css('margin-right',(m_width-10)-(click_x-x)); //set arrow's offset
  }
  
  $('#modal_container').css('left',x);
  $('#modal_container').css('top',y);
};

//issues an ajax call to goto a particular spot on the map
//type is either 'issue' or 'relationship'; id is the id of the element
function recenter(type, id){
	console.log('recenter:', type, id)
	show_progress_message('loading...') //show progress message
	
	cmd = 'goto_'+type
	$.ajax({
	  url: '/mapvisualizations',
	  data: {"do":cmd,target:id},
	  dataType: 'script'
	});     
}

//gets the issue out of a "node", and applies given function to it (currently show_modal)
function get_issue(node, func) {
	// console.log(node.name);
	$.ajax({
		url: '/mapvisualizations',
		data: {'do':'get_issue',id:node.id, x:node.x, y:node.y},
		complete: function(data) {func(data);},
		dataType: 'script'
	});
}

//gets the relationship out of an edge (with the specified parameters {curve, midPoint}), 
//and applies given function to it (currently show_modal)
function get_relationship(edge, params, func) {
	// console.log(edge.name+"\n"+params.curve);
	$.ajax({
		url: '/mapvisualizations',
		data: {'do':'get_relation',id:edge.id, curve:params.curve, x:params.midPoint.x, y:params.midPoint.y},
		complete: function(data) {func(data);},
		dataType: 'script'
	});	
}

//layout details for the node qtip
function get_node_qtip(node) {
	return {
		content:{
			text: 'Loading '+node.name+'...',
			ajax:{
				url: 'mapvisualizations/qtip',
				type: 'GET',
				data: {t: 'issue', id: node.id}
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
		},
		hide: {
			fixed: true,
		},
	};
}

//layout details for the edge qtip
function get_edge_qtip(edge) {
	return {
		content:{
			text: '<div id="relation_qtip"><div class="formcontentdiv"><div class="heading"><a href="">' + 
							edge.name + '</a></div></div></div>'
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
		},
		hide: {
			fixed: true,
		},
	};	
}