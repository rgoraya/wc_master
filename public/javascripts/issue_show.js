/* Javascript for Issue Show page */
$(function() {

// -------------------------------------------------------------------------------
// STUFF TO BE DONE ON THE INITIAL LOAD OF THE PAGE
// -------------------------------------------------------------------------------
	
	$(".relationship_partial_toggle:contains(" + $(".central_causality_container").text() + ")").filter(function(){
	    $(this).hide()
	 })

	$(".relationship_partial_toggle:not(:contains(" + $(".central_causality_container").text() + "))").filter(function(){
	    $(this).show()
	 })

	if (!$("#title_dynamic_text").text().trim().length) {
	    $("#title_filler_text").show();}


	if ($("#title_relationship").text().trim().length) {
		var opaqueDiv = $(".relationship_thumb_title").filter(function() {
			return $(this).text().trim() == $("#title_relationship").text().trim();
         });
         
        $('.relationship_thumb').not(opaqueDiv.parents('.relationship_thumb')).animate({'opacity': '0.3'}); 
         	
         
	}
	
	window.confirm = false;
// -------------------------------------------------------------------------------
// FUNCTION TO CYCLE THROUGH THE VARIOUS RELATIONSHIP TYPES BASED ON USER CLLICK 
// -------------------------------------------------------------------------------
$(".relationship_partial_toggle").live('click',function(){
	
	// Hide the currently displayed relationships
	$(".relationship_thumb, .relationship_none_found, #get_relationships, #title_dynamic_text, .rationale_container").hide();
	// Show spinner
	$(".relationship_addnew_wait").show();

        	$("#select_rel_type").val($(this).text().trim())
        	$("#select_rel_submit").trigger('click');

});	

// -------------------------------------------------------------------------------
// FUNCTIONS TO PAGINATE CAUSES/EFFECTS/INHIBITORS/INHIBITEDS/SUBSETS/SUPERSETS
// -------------------------------------------------------------------------------	

  $("#relation_pagination .pagination a").live("click", function() {
	$("#relations_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
	$.getScript(this.href);	
	return false;
  });


// -------------------------------------------------------------------------------
// FUNCTION TO SHOW SPINNNER WHEN THE NEW RELATIONSHIP IS CREATED
// -------------------------------------------------------------------------------	
	$("#val_collector").click(function(){
		$('.relationship_addnew_wait').show();
		$('.relationship_none_found').hide();
		
		// if more than 5 relationships are displayed then hide the last one to make space!!
		if ($('.relationship_thumb:visible').length > 5){
     		$('.relationship_thumb:visible').last().hide();	
		}  
		
	});


	$(".relationship_thumb a").live('click',function(){
		
		$(this).parents('.relationship_thumb').animate({'opacity': '1'});
		$('.relationship_thumb').not($(this).parents('.relationship_thumb')).animate({'opacity': '0.3'});
					
		$("#relationship_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
  		
  		var relationship_id = $(this).parents('.relationship_thumb').children('.relationship_id_store').html().trim();
		
		$("#title_filler_text").hide();
		
		close_addNew();
		$('.del-relation').attr('href', "../relationships/" + relationship_id);
		
	
		return false;
	});
	

	$(".relationship_addnew a").live('click',function(){
		initialize_addNew();
		$("#modal_form").toggle();		
	});
	
	$('.btn_close, #val_collector, .relationship_partial_toggle').click(function(){
		close_addNew();
	});

// -------------------------------------------------------------------------------
// FUNCTIONS TO INITIALIZE AND TOGGLE ADD_NEW MODAL
// -------------------------------------------------------------------------------	
	function close_addNew() {
		  $("#modal_form").removeAttr('style');
		  $('#title_modalhead').hide();			
	}
	
	function initialize_addNew(){
		  $('#image_preview').removeAttr('style');
		  $('#text_holder ').html('');
		  $('#title_holder').html('');
		  $('#text_preview').removeAttr('style');
		  $("#wait").empty();
		  $('#form_container').css("display", "none");
		  $("#query").val(''); 		
	}

// -------------------------------------------------------------------------------
// RELATIONSHIP DELETE FUNCTIONS
// -------------------------------------------------------------------------------
  var href_carrier = '';
  var bubble_to_remove = '';
        
  $(".del-relation").live('click', function(e) {
  e.preventDefault();
  var title = $(this).data('title');
  var msg = "Are you sure you want to remove this causal link?"
  href_carrier = $(this).attr('href');
  bubble_to_remove = $(this).parents(".bubble");
  showPopup(title, msg);
  return false;      
  });


// -------------------------------------------------------------------------------
// FUNCTION TO DELETE RELATIONSHIP IF YES WAS CLICKED
// -------------------------------------------------------------------------------	
  $("#confirm_yes").live('click', function() {
  	// Show the spinner
  	$("#confirm_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
  	
  	// Make Ajax Call
  	$.ajax({
  		type: "DELETE",
  		url: href_carrier,
	    cache: false,
	    // If Ajax call is succesful
	    success: function(){
		    // Reload partial
		    $("#select_rel_submit").trigger('click');
		    // Do stuff
		    $("#confirm_msg").html('Causal Link Deleted!'); 
		    $("#confirm_buttons").hide(); 
		    $("#confirm_wait").empty();
		    // Remove the modal
		    $("#confirm_popup").delay(2000).fadeOut('slow', function(){
			    $('#fade').delay(2000).remove();
	    		$("#get_relationship .title,#get_relationship .rationale_container").empty();
	  		});
  		   }
  		});  
  });

// -------------------------------------------------------------------------------
// FUNCTION TO REMOVE MODAL IF USER CANCELED DELETION
// -------------------------------------------------------------------------------	
  $("#confirm_cancel").click(function() {
	  $('#fade').remove();
  	  $("#confirm_popup").fadeOut('slow');    
  	  href_carrier = '';
  });

// -------------------------------------------------------------------------------
// SHOW SPINNER ON REFERENCE FORM SUBMISSION
// -------------------------------------------------------------------------------	
  $('#reference_collector').live('click', function(){
  	$("#references_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
  });	
	
	
// -------------------------------------------------------------------------------  
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// ------------------------------------------------------------------------------- 

  // I N I T I A L    F O R M A T T I N G / P R O C E S S I N G
  
  /* (0.) Align the blobs and arrows Correctly based on height of the Issueblock
  $('img.wikiimage').ready(function(){
  var block_height = $('.issueblock').height();
  var arrow_height = $('.arrow-carrier-right').height();
  var blob_height  = $('.blob-carrier').height();
  var right_height = $('.arrow-leftward').height();
  
  var arrow_marg_top = (block_height - arrow_height)/2
  var blob_marg_top  = (block_height - blob_height - 42)/2
  var right_marg_top = (block_height - right_height - 40)/2 
  
  $('.arrow-carrier-right, .arrow-carrier-left').animate({'margin-top': arrow_marg_top});
  $('.blob-carrier').animate({'margin-top': blob_marg_top});
  $('.arrow-leftward').animate({'margin-top': right_marg_top});
  /$(".blue_banner").effect("highlight", {color: '#4DB8DB'}, 1000);
  
  // Ensure that the height of Map remains same as the rest of the content
  var mapcontainer_height = $('.wikicontent').height();
  $('#map_canvas').css({'height': mapcontainer_height});
  });
  // (3.) Show or Hide the Suggestion Scroll buttons if required

  if ($(".cause_carousel").height() > 30){
  $(".cause_scroller").css({display : 'inline'});
  }

  if ($(".effect_carousel").height() > 30){
  $(".effect_scroller").css({display : 'inline'});
  }

  if ($(".inhibitor_carousel").height() > 30){
  $(".inhibitor_scroller").css({display : 'inline'});
  }
  
  if ($(".inhibited_carousel").height() > 30){
  $(".inhibited_scroller").css({display : 'inline'});
  }
    

  // (4.) Show or Hide the Accepted Scroll buttons if required
  if ($(".accepted_causes").height() > 64){
  $(".cause_scroll").css({display : 'block'});
  }

  if ($(".accepted_effects").height() > 64){
  $(".effect_scroll").css({display : 'block'});
  }

  if ($(".accepted_inhibitors").height() > 64){
  $(".inhibitor_scroll").css({display : 'block'});
  }

  if ($(".accepted_inhibited").height() > 64){
  $(".inhibited_scroll").css({display : 'block'});
  }  
  // S M O O T H    D I V    S I Z E    T R A N S I T I O N S (this is cool!)

  // Animates the dimensional changes resulting from altering element contents
  // Usage examples: 
  //    $("#myElement").showHtml("new HTML contents");
  //    $("div").showHtml("new HTML contents", 400);
  //    $(".className").showHtml("new HTML contents", 400, 
  //                    function() {/* on completion *//*});
  (function($)
  {
  $.fn.showHtml = function(html, speed, callback)
  {
  return this.each(function()
  {
  // The element to be modified
  var el = $(this);

  // Preserve the original values of width and height - they'll need 
  // to be modified during the animation, but can be restored once
  // the animation has completed.
  var finish = {width: this.style.width, height: this.style.height};

  // The original width and height represented as pixel values.
  // These will only be the same as `finish` if this element had its
  // dimensions specified explicitly and in pixels. Of course, if that 
  // was done then this entire routine is pointless, as the dimensions 
  // won't change when the content is changed.
  var cur = {width: el.width()+'px', height: el.height()+'px'};

  // Modify the element's contents. Element will resize.
  el.html(html);

  // Capture the final dimensions of the element 
  // (with initial style settings still in effect)
  var next = {width: el.width()+'px', height: el.height()+'px'};

  el .css(cur) 
  el .animate(next, speed, function()  // animate to final dimensions
  {
  el.css(finish); // restore initial style settings
  if ( $.isFunction(callback) ) callback();
  });
  });
  };
  })(jQuery);  
  
  */