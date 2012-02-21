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
  
	setTimeout(function() {
	    $('#notice_container').fadeOut('slow');
	    $('#notice').empty();	
	}, 3000);

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
    var ignore_keys_array = [18,20,17,40,35,13,27,36,45,37,93,91,34,33,39,16,9,38];
    if ($.inArray(e.keyCode, ignore_keys_array) == -1)
		$('#issue_search').html('');
		searchDelay(function(){
    		$('#issue_search').html('<div class="search_result_wait"></div>');    		
    		$.get($("#issue_search_form").attr("action"), $("#issue_search_form").serialize(), null, "script");
		}, 500);     
    
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
	$('#search_invisible_input').val($('#search_visible_input').val())
  	$('#search_form').submit();
  });              

// -------------------------------------------------------------------------------  
// DO THE ABOVE ON HITTING THE RETURN KEY TOO
// -------------------------------------------------------------------------------  
  $("#search_visible_input").bind("keyup", function(f){
	  if (f.keyCode == 13){
		  $('#search_invisible_input').val($('#search_visible_input').val())
		  $('#search_form').submit(); 
  		}
  });
  
// -------------------------------------------------------------------------------    
// SHOW HIDE SEARCH RESULTS BOX
// -------------------------------------------------------------------------------  
  $("#search_visible_input").bind("keyup", function(){ 
	if ($(this).val() == "")
  		$("#issue_search").hide();
  	else
  		$("#issue_search").show();
  });


// -------------------------------------------------------------------------------  
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// -------------------------------------------------------------------------------  
