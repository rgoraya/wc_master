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
  }
  
  $("#notice_container .closebutton").click(function(){
  	$("#notice_container").slideUp(100);
  });

// -------------------------------------------------------------------------------
// PAGINATION FUNCTIONS FOR ISSUE INDEX AND USER PAGE (DROPPING THEM 
// IN TO APPLICATION js INSTEAD OF CREATING SEPERATE FILES FOR THEM)
// -------------------------------------------------------------------------------  
  $("#issues .pagination a").live("click", function() {
    
	$("#issues #issues_wait").html('<img border="0" src="/images/system/spinner.gif"/>');
	$.getScript(this.href);
	return false;
  });

  
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
    var ignore_keys_array = [18,20,17,35,13,27,36,45,37,93,91,34,33,39,16,9,40,38];
    if ($.inArray(e.keyCode, ignore_keys_array) == -1 && $('#search_visible_input').val().trim() != ""){
			$('#issue_search').html('');
			$('#search_visible_input').val($('#search_visible_input').val().trim());
			searchDelay(function(){
    			$('#issue_search').html('<div class="search_result_wait"></div>');    		
    			$.get($("#issue_search_form").attr("action"), $("#issue_search_form").serialize(), null, "script");
			}, 500);
		}     
  });

// -------------------------------------------------------------------------------
// Set the width of the fillers: Width of the element plus horizontal padding
// -------------------------------------------------------------------------------  
  var filler_width = $(".nav_more_click").width() + 4; 
  var filler_big_width = $(".login_form_opener").width() + 26; 
  
  $(".white_filler").css({'width' : filler_width});
  $(".white_filler_big").css({'width' : filler_big_width});

// -------------------------------------------------------------------------------  
// FUNCTIONS TO DISPLAY/HIDE ADDITIONAL LINKS AFTER LOGON
// -------------------------------------------------------------------------------  
  $(".nav_more_click").click(function(){
  
  	var current_state = $(".nav_more_expansion").css("display");
  
  	if (current_state == 'none')
  		{
  		$(this).css({'padding-bottom' : '12px', 'border-bottom':'none', 'background':'#ffffff', 'color':'#434343'});
  		$(".nav_more_expansion").show();
  		}

  	if (current_state == 'block')
  		{
  		$(this).removeAttr('style');
  		$(".nav_more_expansion").removeAttr('style');
  		}
  });
  
// -------------------------------------------------------------------------------  
// Function to HIDE OPEN ACCORDIONS when clicked elsewhere on the page
// -------------------------------------------------------------------------------    
  $('html').click(function() {
	  var current_state = $(".nav_more_expansion").css("display");
	  var current_state_login = $(".login_form_container").css("display");
	  var current_state_search = $("#issue_search").css("display");
  	 
	  if (current_state == 'block')
		  {
		  $(".nav_more_click").removeAttr('style');
		  $(".nav_more_expansion").removeAttr('style');
		  }

	  if (current_state_login == 'block')
		  {
		  $(".login_form_opener").removeAttr('style');
		  $(".login_form_container").removeAttr('style');
		  }

	  if (current_state_search == 'block')
		  {
		  $("#issue_search").removeAttr('style');
		  }
		  });

// -------------------------------------------------------------------------------  
// STOP PROPOGATION to NOT hide if clicked within the accordions themselves
// -------------------------------------------------------------------------------  
  $('.nav_more, .login_main_container, .searchfield_appl, #issue_search').click(function(event){
	  event.stopPropagation();
  });  

// -------------------------------------------------------------------------------  
// FUNCTIONS TO DISPLAY/HIDE LOGON FORM
// -------------------------------------------------------------------------------  
  $(".login_form_opener").click(function(){
  
  	var current_state = $(".login_form_container").css("display");
  
  	if (current_state == 'none')
  		{
  		$(this).css({'padding-bottom' : '10px', 'border-bottom':'none', 'background-color':'#ffffff', 'color':'#434343', 'background-image':'url("/images/system/loginrev.png")'});
	  	$(".login_form_container").show();
	  	$(".login_form_container input:text:visible:first").focus();
  		}

  	if (current_state == 'block')
	  	{
	  	$(this).removeAttr('style');
	  	$(".login_form_container").removeAttr('style');
	  	}
  });

// -------------------------------------------------------------------------------  
// COPY VALUE OF SEARCH BOX AND SUBMIT (HIDDEN) SEARCH FORM
// -------------------------------------------------------------------------------  
  $("#search_submit_btn").click(function(){
		if ($('#search_visible_input').val().trim() != ""){
			$('#search_invisible_input').val($('#search_visible_input').val().trim())
  		$('#search_form').submit();
		}
  });              

// -------------------------------------------------------------------------------  
// DO THE ABOVE ON HITTING THE RETURN KEY TOO
// -------------------------------------------------------------------------------

	window.searchBoxIndex = -1;
  
  $("#search_visible_input").bind("keyup", function(f){
	  if (f.keyCode == 13){
			if (searchBoxIndex < 0){
				if ($('#search_visible_input').val().trim() != ""){
		  		$('#search_invisible_input').val($('#search_visible_input').val().trim())
		  		$('#search_form').submit();
				}
			}
			else{
				window.location = $(".search_result_appl a").eq(searchBoxIndex).attr("href");
			} 
  	}
		else if (f.keyCode == 40){
			Navigate(1);
		}
		else if (f.keyCode == 38){
			Navigate(-1);
		}
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
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// -------------------------------------------------------------------------------  
