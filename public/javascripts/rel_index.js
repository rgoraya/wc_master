/* Javascript for Relationship Index page */
$(function() {

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||    R E L A T I O N S H I P     I N D E X       F U N C T I O N S   ||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	

// -------------------------------------------------------------------------------
// FUNCTIONS FOR PAGINATION
// -------------------------------------------------------------------------------

  $("#relationships .pagination a").live("click", function() {
    // show message to the user
	show_progress_message("retrieving relationships");
	
	// call
	$.getScript(this.href);
	
	// history management
	window.history.ready = true;
	history.pushState(null, document.title, this.href);	
	
	return false;
  });

// -------------------------------------------------------------------------------
// FUNCTIONS FOR CALLING VARIOUS TOOLTIPS
// -------------------------------------------------------------------------------
  var tooltipMsg = {
	   'title_hover_msg': 'Relationships of',
	   'sug_thumb': 'See what Wikipedia says',
	   'iss_thumb': 'About this issue',
	   'rel_link' : 'View this relationship'
  };

  // TOOL-TIP FOR ISSUE LINKS
  $(".formheading a:not(.relationship_linkout)").live('mouseover', function(){
	  tooltip_caller = $(this);
	  tooltip_text   = tooltipMsg.title_hover_msg + " " + $(this).attr('rel');
	  showTooltip(tooltip_caller, tooltip_text);
  });

  // TOOL-TIP FOR ISSUE LINKS
  $(".relationship_linkout").live('mouseover', function(){
	  tooltip_caller = $(this);
	  tooltip_text   = tooltipMsg.rel_link;
	  showTooltip(tooltip_caller, tooltip_text);
  });

  $(".formheading a").live("mouseleave", function(){
	  hideTooltip();
  });


// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
