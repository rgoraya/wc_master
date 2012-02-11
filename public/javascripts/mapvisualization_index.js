/* Functions and such for interacting on the index page (usually ajax-based) */

$(document).ready(function(){
  $("#spinner").css('left',$('#canvas_container').width()/2-32)
    .css('top',$('#canvas_container').height()/2-32)
    .toggle();
  $("form.button_to") //anything formed by the button_to tag apparently
    .bind("ajax:beforeSend", function() {
      $("#spinner").toggle()
    })
    .bind("ajax:complete", function() {
      $("#spinner").toggle()
    })
  $("#clickForm").live('ajax:complete', function(evt, data) {
    show_modal(data);
    //$('#clickForm').children().not('#do').remove();
  });
  $('#modal_container .btn_close').click(function(){
    $('#modal_container').toggle(false);
	});
});

//show the modal window
function show_modal(data) { 
  $('#modal_fill').html(data.responseText);
  $('#modal_container').toggle(true);
};

//put the modal window in the desired location (relative to parent of course)
function position_modal(click_x,click_y) {
  c_width = $('#canvas_container').width(); 
  c_height = $('#canvas_container').height(); 
  m_width = $('#modal_container').width();
  m_height = $('#modal_container').height();
  
  x = Math.min(Math.max(click_x-m_width/2,0),c_width-m_width);
  y = -1*c_height + click_y;

  above = click_y > c_height/2 //if we clicked below the equator, place modal above

  if(above) { //set the arrows and such
    y -= (5+25+m_height) //make room for arrow below
    $('#modal_container .up_pointer_arrow').toggle(false);
    $('#modal_container .down_pointer_arrow').toggle(true);
    $('#modal_container .down_pointer_arrow').css('margin-right',(m_width-20)-(click_x-x)); //set arrow's offset
  }
  else {
    y += 5
    $('#modal_container .up_pointer_arrow').toggle(true);
    $('#modal_container .down_pointer_arrow').toggle(false);
    $('#modal_container .up_pointer_arrow').css('margin-right',(m_width-20)-(click_x-x)); //set arrow's offset
  }
  
  $('#modal_container').css('left',x);
  $('#modal_container').css('top',y);
};
