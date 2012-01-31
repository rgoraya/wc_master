/* Javascript for Issue Show page */
$(function() {
	
	window.confirm = false;
// -------------------------------------------------------------------------------
// FUNCTION TO CYCLE THROUGH THE VARIOUS RELATIONSHIP TYPES BASED ON USER CLLICK 
// -------------------------------------------------------------------------------
$(".relationship_partial_toggle").click(function(){
	
	// Show hidden Div
	$(".relationship_partial_toggle").css({'display' : 'block'})
	
	// Hide this Div
	$(this).hide()
	
	// Hide the currently displayed relationships
	$(".relationship_thumb, .relationship_none_found").hide();
	// Show spinner
	$(".relationship_addnew_wait").show();
	// Ensure that the relationship thimbs are back to opacity = 1
	//$('.relationship_thumb').css({'opacity': '1'});	
	
	//  get the ID name 
	var idName = $(this).attr('id');
	
	switch (idName) { 
        case 'toggle_causes':
        	//$("#causes").show();
        	$("#title_filler_causality").html('Causes')
        	$("#select_rel_type").val('causes')
        	$("#select_rel_submit").trigger('click');
        	
        	break;
		case 'toggle_effects':
			//$("#effects").show();
			$("#title_filler_causality").html('Effects')
        	$("#select_rel_type").val('effects')
        	$("#select_rel_submit").trigger('click');			
			
			break;
		case 'toggle_inhibitors':
			//$("#inhibitors").show();
			$("#title_filler_causality").html('Inhibitors')
        	$("#select_rel_type").val('inhibitors')
        	$("#select_rel_submit").trigger('click');			
			break;
		case 'toggle_inhibiteds':
			//$("#inhibiteds").show();
			$("#title_filler_causality").html('Inhibiteds')
        	$("#select_rel_type").val('inhibiteds')
        	$("#select_rel_submit").trigger('click');
			break;
		case 'toggle_supersets':
			//$("#supersets").show();
			$("#title_filler_causality").html('Supersets')
        	$("#select_rel_type").val('supersets')
        	$("#select_rel_submit").trigger('click');
			break;
		case 'toggle_subsets':
			//$("#subsets").show();
			$("#title_filler_causality").html('Subsets')
        	$("#select_rel_type").val('subsets')
        	$("#select_rel_submit").trigger('click');
			break;
	}
	
	//  get the inner HTML of the top bar and the one clicked
	var central_htmlstr = $(".central_causality_container").html().trim();
	var htmlstr = $(this).html().trim();
	
	//  replace the HTML of the top bar with the one clicked and highlight it!
	$(".central_causality_container").html(htmlstr);
	//$(".relationship_thumb_title").effect("highlight", {color: '#4DB8DB'}, 500);
	
	$('#title_filler_text').show();
	$('#title_dynamic_text').hide()
	$('.rationale_container').fadeOut();
	
});	

// -------------------------------------------------------------------------------
// FUNCTIONS TO PAGINATE CAUSES/EFFECTS/INHIBITORS/INHIBITEDS/SUBSETS/SUPERSETS
// -------------------------------------------------------------------------------	

  $("#relation_pagination .pagination a").live("click", function() {
	$("#relations_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);	
	return false;
  });

  $("#effect_pagination .pagination a").live("click", function() {
	$("#effects_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);	
	return false;
  });

  $("#inhibitor_pagination .pagination a").live("click", function() {
	$("#inhibitors_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);	
	return false;
  });

  $("#inhibited_pagination .pagination a").live("click", function() {
	$("#inhibiteds_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);	
	return false;
  });	

  $("#subset_pagination .pagination a").live("click", function() {
	$("#subsets_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);
	return false;
  });

  $("#superset_pagination .pagination a").live("click", function() {
	$("#supersets_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);	
	return false;
  });


// -------------------------------------------------------------------------------
// FUNCTION TO SHOW SPINNNER WHEN THE NEW RELATIONSHIP IS CREATED
// -------------------------------------------------------------------------------	
	$("#val_collector").click(function(){
		$('.relationship_addnew_wait').show();
		
		
		if ($('.relationship_thumb:visible').length > 5){
     		$('.relationship_thumb:visible').last().hide();	
		}  
		
	});


	$(".relationship_thumb a").live('click',function(){
		
		$(this).parents('.relationship_thumb').animate({'opacity': '1'});
		$('.relationship_thumb').not($(this).parents('.relationship_thumb')).animate({'opacity': '0.3'});
					
		
		var issue_descr = $(".main_thumb_title a").attr('rel');
		var issue_title = $(".main_thumb_title a").text();
		var relationship_descr = $(this).attr('rel');
		var relationship_title = $(this).text();
  		var relationship_id = $(this).parents('.relationship_thumb').children('.relationship_id_store').html().trim();
		
		
		$('.del-relation').attr('href', "../relationships/" + relationship_id);
			
		$('#title_modalhead').hide()
		$('#title_filler_text').hide();
		$('#title_dynamic_text').hide()
		$('#title_dynamic_text').show()
		$('#title_issue').html(issue_title);
		$('#title_causality').html($('.central_causality_container').html())
		$('#title_relationship').html(relationship_title);
		$('#permalink_display').html(document.location.hostname + "/relationships/" + relationship_id + "-" +  $('#title_dynamic_text').text().trim().replace(/\s+/g, '-').toLowerCase());
		$('#relation_title_dynamic').html(relationship_title);
		$('#relation_descr_dynamic').html(relationship_descr);
		$('.rationale_container').hide();
		$('.rationale_container').fadeIn();
		$('#reference_form_rel_id').val(relationship_id);
		
		$('#referencesubmit').trigger('click');
		
		return false;
		
	});
	

	$(".relationship_addnew a").live('click',function(){
		
		initialize_addNew();
		
		$('.rationale_container').fadeOut();
		$('.relationship_thumb').animate({'opacity': '0.3'});
		
		$("#modal_form").toggle();
		
		$('#title_dynamic_text').hide();
		$('#title_filler_text').hide();
		$('#title_modalhead').show();
		
	});
	
	$('.btn_close, #val_collector, .relationship_partial_toggle, .relationship_thumb a').click(function(){
		close_addNew();
		
	});

	function close_addNew() {
		  $("#modal_form").removeAttr('style');
		  //$('.relationship_thumb').removeAttr('style');
		  $('#title_filler_text').show();
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

  // D E L E T E     C O N F I R M A T I O N
  var href_carrier = '';
  var bubble_to_remove = '';
        
  $(".del-relation").live('click', function(e) {
  e.preventDefault();
  var title = $(this).data('title');
  var msg = "Are you sure you want to remove the causal link " + $('#relation_title_dynamic').html(); + "?"
  href_carrier = $(this).attr('href');
  bubble_to_remove = $(this).parents(".bubble");
  showPopup(title, msg);
  return false;      
  });

  $("#confirm_yes").live('click', function() {
  
  $("#confirm_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
  $.ajax({
  type: "DELETE",
  url: href_carrier,
  cache: false,
  success: function(){
  $.getScript(href_carrier);
  $("#confirm_msg").html('Causal Link Deleted!'); 
  $("#confirm_buttons").hide(); 
  $("#confirm_wait").empty();
  $("#confirm_popup").delay(2000).fadeOut('slow', function(){
  $('#fade').delay(2000).remove();
  });
  
  }
  });  
  //location.href = href_carrier;
  });
    
  $("#confirm_cancel").click(function() {
  $('#fade').remove();
  $("#confirm_popup").fadeOut('slow');    
  href_carrier = '';
  });

	
});

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