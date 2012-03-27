var accordion_is_being_hovered = false;
var ignore_keys_array = [18,20,17,35,13,27,36,45,37,93,91,34,33,39,16,9,40,38];

$(function() {

// -------------------------------------------------------------------------------
// STUFF TO BE DONE ON THE INITIAL LOAD OF THE PAGE
// -------------------------------------------------------------------------------

  // DISMISS THE FLASH NOTICE
  if ($.trim($("#error").text()) != "")
  {
	  $("#error_container").effect("highlight", {color: '#b84030'}, 800);
	  $('#error').css("display","block");
  }
  
  $("#error_container a.closebutton").click(function(){
	  $("#error_container").slideUp(100);
  });


  // DISMISS THE FLASH NOTICE
  if ($.trim($('#notice').text()) != "") {
  	$("#notice_container").effect("highlight", {color: '#4DB8DB'}, 800);
  	$('#notice').show;

	setTimeout(function() {
	    $('#notice_container').fadeOut('slow');
	    $('#notice').empty();	
	}, 3000);

  }

// -------------------------------------------------------------------------------
// KEEP THE NAVBAR & ACCORDIONS IN VIEW IF WINDOW IS SMALLER THAN 1080PX
// ------------------------------------------------------------------------------- 
	if ($(window).width() < 1060){
	  	$(".headnav, #nav_accordions").width($(window).width());
	}

	$(window).resize(function() {
	  var winWidth = $(window).width();
	  if (winWidth < 1060){
	  	$(".headnav, #nav_accordions").width($(window).width());
	  }
	  if (winWidth >= 1060 && $(".headnav").width() != 1060 ){
	  	$(".headnav, #nav_accordions").width(1060)
	  }   
	});

// -------------------------------------------------------------------------------
// SET THE WIDTH OF THE FILLERS: WIDTH OF THE ELEMENT PLUS HORIZONTAL PADDING
// -------------------------------------------------------------------------------  
  var filler_width = $(".nav_more_click").width() + 4; 
  var filler_big_width = $(".login_form_opener").width() + 26; 
  
  $(".white_filler").css({'width' : filler_width});
  $(".white_filler_big").css({'width' : filler_big_width});
  
// -------------------------------------------------------------------------------
// PAGINATION FUNCTIONS 
// -------------------------------------------------------------------------------  
  
  $("#userissues .pagination a").live("click", function() {
	$("#userissues #issues_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);
	return false;
  });


  $("#activity_pagination .pagination a").live("click", function() {    
	$("#activities_wait").html('<img border="0" src="/images/system/spinnerfe.gif"/>');
	$.getScript(this.href);
	return false;
  });

// -------------------------------------------------------------------------------
// AUTO COMPLETE SEARCH FUNCTIONS	
// -------------------------------------------------------------------------------
	var searchDelay = (function(){
	  var timer = 0;
	  return function(callback, ms){
	    clearTimeout (timer);
	    timer = setTimeout(callback, ms);
	  };
	})();

	
  $("#issue_search_form input").bind('keyup', function(e) { 
    if ($.inArray(e.keyCode, ignore_keys_array) == -1 && $('#search_visible_input').val().trim() != ""){
			$('#issue_search').html('');
			searchDelay(function(){
				if ($('#search_visible_input').val().trim() != ""){
    				$('#issue_search').html('<div class="search_result_wait"></div>');    		
    				$.get($("#issue_search_form").attr("action"), $("#issue_search_form").serialize(), null, "script");
				}
			}, 500);
		}     
  });

// -------------------------------------------------------------------------------  
// SEARCH FORM SUBMISSION
// -------------------------------------------------------------------------------  
  $("#search_submit_btn").click(function(){
		if ($('#search_visible_input').val().trim() != ""){
			$('#issue_search_form').submit();
		}
  });              

// -------------------------------------------------------------------------------  
// ARROW KEY FUNCTION AND RETURN KEY FORM SUBMISSION FOR SEARCH FORM
// -------------------------------------------------------------------------------

  window.searchBoxIndex = -1;
  
  $("#search_visible_input").bind("keyup", function(f){
  	if ($.inArray(f.keyCode, ignore_keys_array) == -1){
  	  searchBoxIndex = -1;}	  
	  
	  if (f.keyCode == 13){
			if (searchBoxIndex < 0){
				if ($('#search_visible_input').val().trim() != ""){
		  			//$('#search_invisible_input').val($('#search_visible_input').val().trim())
		  			$('#issue_search_form').submit();
				}
			}
			else{
				window.location = $(".search_result_appl a").eq(searchBoxIndex).attr("href");
				return false;
			}
  	}
		else if (f.keyCode == 40){
			Navigate(1);
		}
		else if (f.keyCode == 38){
			Navigate(-1);
		}
  });

  var Navigate = function(diff) {
  	searchBoxIndex += diff;
  	var oBoxCollection = $(".search_result_appl");
  	if (searchBoxIndex >= oBoxCollection.length)
  		searchBoxIndex = 0;
  	if (searchBoxIndex < 0)
  		searchBoxIndex = oBoxCollection.length - 1;
  	var elem_class = "search_hover";
  	oBoxCollection.removeClass(elem_class).eq(searchBoxIndex).addClass(elem_class);
  }

  $(".search_result_appl").live('mouseover', function(){
	  searchBoxIndex = $(this).index();
	  var elem_class = "search_hover";
	  var oBoxCollection = $(".search_result_appl");
	  oBoxCollection.removeClass(elem_class).eq(searchBoxIndex).addClass(elem_class);  
  });
  
// -------------------------------------------------------------------------------    
// SHOW HIDE SEARCH RESULTS BOX
// -------------------------------------------------------------------------------  
  $("#search_visible_input").bind("keyup", function(){ 
	if ($(this).val().trim() == "")
  		$("#issue_search").empty();
  	else
  		$("#issue_search").show();
  });

// -------------------------------------------------------------------------------  
// FUNCTIONS TO DISPLAY/HIDE ADDITIONAL LINKS AFTER LOGON
// -------------------------------------------------------------------------------  
  $(".nav_more_click").click(function(){
  	
  	$(".nav_more_expansion").toggle()
  	if ($(".nav_more_expansion").is(":visible")) {
  		$(this).css({'padding-bottom' : '12px', 'border-bottom':'none', 'background':'#ffffff', 'color':'#434343'});
			// hide sort order options if open! 
	  		if ($("#sort_order_options").is(":visible")){
				$("#sort_order_options").hide();
				$("#sort_up_or_down").html("&#x25BC;")
	  		}

  	} else {
  		$(this).removeAttr('style');
  	}
  });

// -------------------------------------------------------------------------------  
// FUNCTIONS TO DISPLAY/HIDE LOGON FORM
// -------------------------------------------------------------------------------  
  $(".login_form_opener").click(function(){

	  	$(".login_form_container").toggle();
	  
	  	if ($(".login_form_container").is(":visible")) {
	  		$(this).css({'padding-bottom' : '10px', 'border-bottom':'none', 'background-color':'#ffffff', 'color':'#434343', 'background-image':'url("/images/system/loginrev.png")'});
		  	$(".login_form_container input:text:visible:first").focus();

			// hide sort order options if open! 
	  		if ($("#sort_order_options").is(":visible")){
				$("#sort_order_options").hide();
				$("#sort_up_or_down").html("&#x25BC;")
			}
		  	
	  	} else 	{
		  	$(this).removeAttr('style');
		  	$(".login_form_container").removeAttr('style');
		  	}
  });
  
// -------------------------------------------------------------------------------  
// FUNCTION TO HIDE ANY OPEN ACCORDIONS WHEN CLICKED ELSEWHERE ON THE PAGE
// -------------------------------------------------------------------------------    

    $('.nav_more, .login_main_container, #nav_accordions, .add_new_relation_modal, .searchfield_appl, #issue_search, #sort_order_options').hover(function(){ 
        accordion_is_being_hovered = true; 
    	}, function(){ 
        accordion_is_being_hovered = false; 
    });

	$("#sort_order").live({
        mouseenter:
           function()
           {
			accordion_is_being_hovered = true; 
           },
        mouseleave:
           function()
           {
			accordion_is_being_hovered = false;
           }
     });

  $('body').click(function() {
		
		if(! accordion_is_being_hovered){
        	
        	if ($(".login_form_container").is(":visible")){
         		$(".login_form_opener").removeAttr('style');
		  		$(".login_form_container").removeAttr('style');
         	}         
	  
	  		if ($(".nav_more_expansion").is(":visible")){
				$(".nav_more_click").removeAttr('style');
		  		$(".nav_more_expansion").removeAttr('style');
	  		}

	  		if ($("#issue_search").is(":visible")){
				$("#issue_search").removeAttr('style');
	  		}
	  		
	  		if ($("#sort_order_options").is(":visible")){
	  			$("#sort_order_options").hide();
				$("#sort_up_or_down").html("&#x25BC;")
	  		}
	  		
	  		if ($(".add_new_relation_modal").is(":visible")){
	  			$("#modal_form").removeAttr('style');		
	  		}
	  		
		}	  
	});


// -------------------------------------------------------------------------------
// SORT ORDER CONTROLS
// -------------------------------------------------------------------------------

	$("#sort_order").live("click", function(){
		// show/hide the sort options
		$("#sort_order_options").toggle();
		
		// display arrow down if options are closed and arrow up if options are open
		if ($("#sort_order_options").is(":visible")){
			$("#sort_up_or_down").html("&#x25B2;")
		  	$("#sort_order_options").css({
		  		"width" : $("#sort_order").width() + 12,
			});
		
			if ($(".login_form_container").is(":visible")){
			  	$(".login_form_opener").removeAttr('style');
			  	$(".login_form_container").removeAttr('style');		
			}

			if ($(".nav_more_expansion").is(":visible")){
			  	$(".nav_more_click").removeAttr('style');
			  	$(".nav_more_expansion").removeAttr('style');		
			}
		
		} else{
			$("#sort_up_or_down").html("&#x25BC;")
		}
		
	});

// -------------------------------------------------------------------------------
// SORT FORM SUBMISSION
// -------------------------------------------------------------------------------
	$(".sort_option").live("click", function(){
		// populate the hidden form field
		$("#order_form_select").val($(this).text().trim())
		
		// hide sort options
		$("#sort_order_options").removeAttr('style');
		
		// show progress message
		show_progress_message("sorting")
		
		// submit the form
		$.get($("#order_form").action, $("#order_form").serialize(), null, "script");
		
		// History management	
		window.history.ready = true;
		history.pushState(null, document.title, $("#order_form").attr("action") + "?" + $("#order_form").serialize());
	
	});



// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||



// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
// S H O W I N G     A N D    H I D I N G    P R O G R E S S    M E S S A G E S 
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 

	function show_progress_message(msg){
		$("#progress_icon").addClass("progress_load_icon")
		$("#progress_message").html(msg);
		$("#progress_container").show();		
	}

	function show_error_message(msg){
		$("#progress_icon").addClass("progress_error_icon")
		$("#progress_message").html(msg);
		$("#progress_container").show();		
		setTimeout(function() {
		    hide_progress_message();	
		}, 2000);
	} 

	function show_success_message(msg){
		$("#progress_icon").addClass("progress_success_icon")
		$("#progress_message").html(msg);
		$("#progress_container").show();		
		setTimeout(function() {
		    hide_progress_message();	
		}, 2000);
	} 	

	function hide_progress_message(){
		$("#progress_icon").removeClass();
		$("#progress_message").html('');
		$("#progress_container").hide();		
	}	
	
	
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
// T O O L T I P    D I S P L A Y    A N D    H I D E 
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 

  function showTooltip(tooltip_caller, tooltip_text){
  	
  	// Initialize tooltip text
  	$(".txt-tooltip").html(tooltip_text);

  	// Set CSS width first so that the top and left can be determined
  	$("#tool_tip").css({
  		"min-width" : tooltip_caller.width(),
	});
	
  	// Set CSS properties
  	$("#tool_tip").css({
  		"top"   : (tooltip_caller.offset().top  - ($("#tool_tip").height() + 2)), 
  		"left"  : (tooltip_caller.offset().left + parseInt(tooltip_caller.css("padding-left").replace("px", "")))  		
  	});

  	// Show it	
  	$("#tool_tip").show();

  }

  function hideTooltip(){
  	$('.txt-tooltip').empty();
  	$("#tool_tip").hide();  	
  }	

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 
// B R O W S E R    H I S T O R Y    N A V I G A T I O N  
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| 

	$(window).bind('popstate', function (ev){
  		if (!window.history.ready && !ev.originalEvent.state)
    		return; // workaround for popstate on load
    	else
  			show_progress_message("loading")
    		$.getScript(location.href);    		
	});
