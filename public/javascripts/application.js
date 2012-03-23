
var accordion_is_being_hovered = false;

$(function() {

// -------------------------------------------------------------------------------
// STUFF TO BE DONE ON THE INITIAL LOAD OF THE PAGE
// -------------------------------------------------------------------------------

  // D I S M I S S    T H E    F L A S H    N O T I C E
  if ($.trim($("#error").text()) != "")
  {
	  $("#error_container").effect("highlight", {color: '#b84030'}, 800);
	  $('#error').css("display","block");
  }
  
  $("#error_container a.closebutton").click(function(){
	  $("#error_container").slideUp(100);
  });


  // D I S M I S S    T H E    F L A S H    N O T I C E
  if ($.trim($('#notice').text()) != "") {
  	$("#notice_container").effect("highlight", {color: '#4DB8DB'}, 800);
  	$('#notice').show;

	setTimeout(function() {
	    $('#notice_container').fadeOut('slow');
	    $('#notice').empty();	
	}, 3000);

  }

// -------------------------------------------------------------------------------
// Set the width of the fillers: Width of the element plus horizontal padding
// -------------------------------------------------------------------------------  
  var filler_width = $(".nav_more_click").width() + 4; 
  var filler_big_width = $(".login_form_opener").width() + 26; 
  
  $(".white_filler").css({'width' : filler_width});
  $(".white_filler_big").css({'width' : filler_big_width});
  
// -------------------------------------------------------------------------------
// PAGINATION FUNCTIONS FOR ISSUE INDEX AND USER PAGE (DROPPING THEM 
// IN TO APPLICATION js INSTEAD OF CREATING SEPERATE FILES FOR THEM)
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

	
  $(".issue_search_form input").on('keyup', function(e) {
		var appl = $(this).parents('.search_container_appl') //the container we're inside
		var searchform = appl.find('.issue_search_form')
		var searchfield = appl.find('.searchfield_appl')
		var issuesearch = appl.find('.issue_search')
		// console.log('appl',appl)
		// console.log("searchform:",searchform)
		// console.log("searchfield:",searchfield)
		// console.log("issuesearch:",issuesearch)
		// console.log($(appl))
		//search_visible_input has class 'searchfield_appl'
		
    var ignore_keys_array = [18,20,17,35,13,27,36,45,37,93,91,34,33,39,16,9,40,38];
    if ($.inArray(e.keyCode, ignore_keys_array) == -1 && searchfield.val().trim() != ""){
			issuesearch.html('');
			searchDelay(function(){
				if (searchfield.val().trim() != ""){
    				issuesearch.html('<div class="search_result_wait"></div>');    		
    				$.get(searchform.attr("action"), searchform.serialize(), null, "script");
				}
			}, 500);
		}     

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
// Function to HIDE OPEN ACCORDIONS when clicked elsewhere on the page
// -------------------------------------------------------------------------------    
	$('.nav_more, .login_main_container, .searchfield_appl, #issue_search, #sort_order_options').hover(function(){ 
	    accordion_is_being_hovered = true; 
		}, function(){ 
	    accordion_is_being_hovered = false; 
	});

	$("#sort_order").live({
		mouseenter: function(){
			accordion_is_being_hovered = true; 
    },
    mouseleave: function(){
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

	  		if ($("#sort_order_options").is(":visible")){
	  			$("#sort_order_options").hide();
					$("#sort_up_or_down").html("&#x25BC;")
	  		}

			  var searches = $(".issue_search");
				for(var i=0, len=searches.length; i<len; i++){ //go through all the searches
		  		if ($(searches[i]).is(":visible")){
						$(searches[i]).removeAttr('style');
		  		}
				}
		}	  
	});

// -------------------------------------------------------------------------------  
// STOP PROPOGATION to NOT hide if clicked within the accordions themselves
// -------------------------------------------------------------------------------  
	// <<<<<<< HEAD:public/javascripts/application.js
	//   $('.nav_more, .login_main_container, .searchfield_appl').click(function(event){
	// 		window.searchBoxIndex = -1 //reset the searchBoxIndex no matter what
	// 	  event.stopPropagation();
	//   });  
	// =======
  //$('.nav_more, .login_main_container, .searchfield_appl').click(function(e){
	//  e.stopPropagation();
//  });  

// -------------------------------------------------------------------------------
// S O R T    O R D E R    C O N T R O L S
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
// S O R T    F O R M    S U B M I S S I O N
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


// -------------------------------------------------------------------------------  
// COPY VALUE OF SEARCH BOX AND SUBMIT (HIDDEN) SEARCH FORM
// -------------------------------------------------------------------------------  
  $(".search_appl_submit").click(function(){
		var form = $(this).parent()
		if (form.children('.searchfield_appl').val().trim() != ""){
			//$('#search_invisible_input').val($('#search_visible_input').val().trim())
  			form.submit();
		}
  });

// -------------------------------------------------------------------------------  
// DO THE ABOVE ON HITTING THE RETURN KEY TOO
// -------------------------------------------------------------------------------

	window.searchBoxIndex = -1; //this may cause odd behavior with multiple searchboxes
   
  $(".searchfield_appl").bind("keydown", function(f){
	  if (f.keyCode == 13){
			if (searchBoxIndex < 0){
				if ($(this).val().trim() != ""){
						$(this).parent().submit();
				}
			}
			else{
				var appl = $(this).parents('.search_container_appl')
				var item = appl.find(".search_result_appl a").eq(searchBoxIndex);
				//var location = appl.find(".search_result_appl a").eq(searchBoxIndex).attr("href");
				appl.find('#selected_data').val(item.attr("href"));
	  		appl.find('.issue_search').empty(); //hide the container for future searches
				$(this).val(item.attr('name'))
				// $(this).parent().submit() //why does this not submit data-remote forms??
				// return false;

				//clear out anything else that we already set??

				// // window.location = $(this).parents('.search_container_appl').find(".search_result_appl a").eq(searchBoxIndex).attr("href");
			}
  	}
		else if (f.keyCode == 40){
			Navigate(1, $(this));
		}
		else if (f.keyCode == 38){
			Navigate(-1, $(this));
		}
  });
  
// -------------------------------------------------------------------------------    
// SHOW HIDE SEARCH RESULTS BOX
// -------------------------------------------------------------------------------  
  $(".searchfield_appl").on("keyup", function(){
		var appl = $(this).parents('.search_container_appl') //the container we're inside
		if ($(this).val().trim() == "") //hide if empty string I think
  		appl.find('.issue_search').empty();
  	else
  		appl.find('.issue_search').show();
  });

                   
  var Navigate = function(diff, searcher) {
  	searchBoxIndex += diff;
  	var oBoxCollection = searcher.parents('.search_container_appl').find(".search_result_appl");
  	if (searchBoxIndex >= oBoxCollection.length)
			searchBoxIndex = oBoxCollection.length - 1; //to not wrap
  		// searchBoxIndex = 0;
  	if (searchBoxIndex < 0)
			searchBoxIndex = 0;
  		// searchBoxIndex = oBoxCollection.length - 1;
  	var elem_class = "search_hover";
	  oBoxCollection.removeClass(elem_class).eq(searchBoxIndex).addClass(elem_class);
  }

  $(".search_result_appl").on('mouseover', function(){
	  searchBoxIndex = $(this).index();
	  var elem_class = "search_hover";
	  var oBoxCollection = $(".search_result_appl");
	  oBoxCollection.removeClass(elem_class).eq(searchBoxIndex).addClass(elem_class);  
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
		var spinner_html = '<img src="/images/system/spinnerf6.gif" class="progress_spinner"/>'
		$("#progress_message").html(spinner_html + msg);
		$("#progress_container").show();		
	}

	function hide_progress_message(){
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
  		"top"   : tooltip_caller.offset().top  - $("#tool_tip").height(), 
  		"left"  : tooltip_caller.offset().left + parseInt(tooltip_caller.css("padding-left").replace("px", ""))  		
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
