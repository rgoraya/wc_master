/* Javascript for Issue Index page */
$(function() {

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||    I S S U E      I N D E X       F U N C T I O N S   |||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	

// -------------------------------------------------------------------------------
// D E L E T E     C O N F I R M A T I O N
// -------------------------------------------------------------------------------  

// UNCOMMENT THE following lines of code to get the custom confirm box to show

  window.confirm = false;
  
  var href_carrier;
        
  $(".del-issue").live('click', function() {
  	  var title = "Delete Issue?";
	  var msg = $(this).data('confirm');
	  href_carrier = $(this).attr('href');
	  showPopup(title, msg);

	  return false;
  });


// -------------------------------------------------------------------------------
// DELETE CONFIRMATION 'YES' 
// -------------------------------------------------------------------------------  

  $("#confirm_yes").live('click', function() {
  	$("#confirm_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
	href_carrier = href_carrier + "?sort_by=" + $("#sort_current_criteria").text().trim()
	$.post(href_carrier, {_method:'delete'}, null, "script");
  });

// -------------------------------------------------------------------------------
// DELETE CONFIRMATION 'CANCEL' 
// ------------------------------------------------------------------------------- 
    
  $("#confirm_cancel").live('click', function() {
	  $('#fade').remove();
	  $("#confirm_popup").fadeOut('slow');  
	  href_carrier = '';
  });

// -------------------------------------------------------------------------------
// SHOW DELETE CONFIRMATION  
// -------------------------------------------------------------------------------

  function showPopup(title, msg) {
	  $("#confirm_title").html(title);
	  $("#confirm_msg").html(msg);
	  $("#confirm_buttons").show();
	  $('body').append('<div id="fade"></div>'); //Add the fade layer to bottom of the body tag.
	  $('#fade').css({'filter' : 'alpha(opacity=80)'}).fadeIn(); //Fade in the fade layer 
	  $("#confirm_popup").fadeIn();
  }   

// -------------------------------------------------------------------------------
// ISSUES PAGINATION 
// ------------------------------------------------------------------------------- 
  $("#issues .pagination a").live("click", function() {
	// show message to the user
	show_progress_message("retrieving issues")
	// call
	$.getScript(this.href);	
	// history management
	window.history.ready = true;
	history.pushState(null, document.title, this.href);	
	return false;
  });


// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
