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


	  var searches = $(".issue_search");
		for(var i=0, len=searches.length; i<len; i++){ //go through all the searches
			var state = $(searches[i]).css("display");			
		  if (state == 'block'){
			  $(searches[i]).removeAttr('style');
			}
		}

	});

// -------------------------------------------------------------------------------  
// STOP PROPOGATION to NOT hide if clicked within the accordions themselves
// -------------------------------------------------------------------------------  
  $('.nav_more, .login_main_container, .searchfield_appl').click(function(event){
		window.searchBoxIndex = -1 //reset the searchBoxIndex no matter what
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







// -------------------------------------------------------------------------------  
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// -------------------------------------------------------------------------------  
