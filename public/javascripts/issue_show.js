/* Javascript for Issue Show page */
$(function() {

// -------------------------------------------------------------------------------
// STUFF TO BE DONE ON THE INITIAL LOAD OF THE PAGE
// -------------------------------------------------------------------------------
	
	// If the relationship_type is known then add class to the corresponding relationship_partial_toggle
	if (this_relationship_type){
		$(".relationship_partial_toggle:contains(" + this_relationship_type + ")").filter(function(){
		  $(this).addClass("central_causality_container")
		});		
	}

	// Form sentence 
	if (!$("#title_dynamic_text").text().trim().length) {
	    $("#title_filler_text").show();}

	// Make the correct thumbnail opque
	if ($("#title_relationship").text().trim().length) {
		var opaqueDiv = $(".relationship_thumb_title").filter(function() {
			return $(this).text().trim() == $("#title_relationship").text().trim();
         });
         // make the rest of the Divs transparent
        $('.relationship_thumb').not(opaqueDiv.parents('.relationship_thumb')).animate({'opacity': '0.3'}); 
        // Hide ellipsis
        $("#title_relationship_ellipsis").hide();
        // Show the linkout button for this thumbnail         	
		opaqueDiv.siblings(".issue_linkout").fadeIn();
	}

// -------------------------------------------------------------------------------
// FUNCTION TO GO BACK TO DEFAULT STATE OF SHOW PAGE (ISSUE SPECIFIC INFO)
// -------------------------------------------------------------------------------
	$(".main_thumb_title a, .issue_thumb_main a").live('click', function(){
		
		// Revert styles (if any) to default 
		$('.relationship_thumb').removeAttr('style');
		$(".relationship_thumb_suggestion").removeAttr('style').removeClass('suggestion_selected');	
		$(".relationship_thumb .issue_linkout").removeAttr('style');
		
		// Show progress message
		show_progress_message('loading')
		
		// History management	
		window.history.ready = true;
		history.pushState(null, document.title, this.href);
	})
	
	
// -------------------------------------------------------------------------------
// FUNCTION TO CYCLE THROUGH THE VARIOUS RELATIONSHIP TYPES BASED ON USER CLLICK 
// -------------------------------------------------------------------------------
	$(".relationship_partial_toggle a").live('click',function(){
		
		// Show message
		show_progress_message("loading relationships");

		// history management
		window.history.ready = true;
		history.pushState(null, document.title, this.href);	
		return false;
		
	});	

// -------------------------------------------------------------------------------
// SENTENCE FORMATION ON HOVERING UPON RELATIONSHIP_TYPES
// -------------------------------------------------------------------------------

	$(".relationship_partial_toggle:not(.central_causality_container)").live('mouseover', function(){
		
		// Hide Stuff:
		$("#title_relationship, #title_causality").hide();
		
		// Show causality
	    $("#title_causality_hover").html($(this).text().trim())	
		$("#title_causality_hover, #title_relationship_ellipsis").show();
	});	
	
	$(".relationship_partial_toggle:not(.central_causality_container)").live('mouseout', function(){
		
		// show Stuff:
		$("#title_relationship, #title_causality").show();
		
		// hide causality
	    $("#title_causality_hover").html('');
	    $("#title_causality_hover").hide();
		
		// hide ellipsis if relationship span has some text
		if ($("#title_relationship").text().trim() != "" ){
			$("#title_relationship_ellipsis").hide();	
		}    
	});	

// -------------------------------------------------------------------------------
// SENTENCE FORMATION ON HOVERING UPON RELATIONSHIP THUMBNAILS
// -------------------------------------------------------------------------------

	$(".relationship_thumb:not(.selected_relationship_thumb, .selected_suggestion_thumb)").live('mouseover', function(){
		
		// Remove other classes 
		$("#title_causality").removeClass('suggested_causality')
		// Hide Stuff:
		$("#title_relationship, #title_relationship_ellipsis").hide();
		
		// Show causality
		$("#title_causality").html($(".central_causality_container").text().trim());
	    $("#title_relationship_hover").html($(this).children(".relationship_thumb_title").text().trim());	
		$("#title_relationship_hover").show();
	});	
	
	$(".relationship_thumb:not(.selected_relationship_thumb, .selected_suggestion_thumb)").live('mouseout', function(){
		
		// Show stuff
		$("#title_relationship").show();
		
		// Show ellipsis only if nothing's there in relationship span
		if ($("#title_relationship").text().trim() == "" ){
			$("#title_relationship_ellipsis").show();	
		}
		
		// Hide stuff
	    $("#title_relationship_hover").html('');	
		$("#title_relationship_hover").hide();
		
		// If some suggestion was selected then
		if ($(".selected_suggestion_thumb")[0]){
	   		$("#title_causality").html(suggestion_hover_sentence()).addClass('suggested_causality');
		}
		
	});	

// -------------------------------------------------------------------------------
// SENTENCE FORMATION ON HOVERING UPON SUGGESTION THUMBNAILS
// -------------------------------------------------------------------------------

	$(".suggestion_thumb:not(.selected_suggestion_thumb)").live('mouseover', function(){
		
		// Hide Stuff:
		$("#title_relationship, #title_relationship_ellipsis, #title_causality").hide();
		
		// Show causality
	    $("#title_relationship_hover").html($(this).children(".relationship_suggestion_title").text().trim());	
		$("#title_causality").html(suggestion_hover_sentence()).addClass('suggested_causality');
		$("#title_relationship_hover, #title_causality").show();
	});	
	
	$(".suggestion_thumb:not(.selected_suggestion_thumb)").live('mouseout', function(){
		
		// Show stuff
		$("#title_relationship, #title_causality").show();
	
		// Show ellipsis only if nothing's there in relationship span
		if ($("#title_relationship").text().trim() == "" ){
			$("#title_relationship_ellipsis").show();	
		}
	
		// If some suggestion was selected then
		if ($(".selected_suggestion_thumb")[0]){
	   		$("#title_causality").html(suggestion_hover_sentence()).addClass('suggested_causality');
		} else{
			$("#title_causality").html($(".central_causality_container").text().trim()).removeClass('suggested_causality');
		}
	
		// Hide stuff
	    $("#title_relationship_hover").html('');	
		$("#title_relationship_hover").hide();
	});	

// -------------------------------------------------------------------------------
// CREATING SUGGESTION CAUSAL SENTENCE BASED ON CURRENT RELATIONSHIP TYPE
// -------------------------------------------------------------------------------

  function suggestion_hover_sentence(){
  	
  	var current_sentence = $(".central_causality_container").text().trim();
	var suggestion_sentence = ""
	
	switch (current_sentence) { 
	  case 'is caused by':
		suggestion_sentence = 'may be caused by';
	  break;
	  case 'causes':
		suggestion_sentence = 'may cause';
	  break;
	  case 'is reduced by':
		suggestion_sentence = 'may be reduced by';
	  break;
	  case 'reduces':
		suggestion_sentence = 'may reduce';
	  break;
	  case 'includes':
		suggestion_sentence = 'may inlude';
	  break;
	  case 'is a part of':
		suggestion_sentence = 'may be a part of';
	  break;
	  }
	
	return suggestion_sentence;
  	 
  }

// -------------------------------------------------------------------------------
// FUNCTION TO PAGINATE CAUSES/EFFECTS/INHIBITORS/INHIBITEDS/SUBSETS/SUPERSETS
// -------------------------------------------------------------------------------	

  $("#relation_pagination .pagination a").live("click", function() {
	// Show progress message to user
	show_progress_message("loading")
	// make the call
	$.getScript(this.href);
	// history management
	window.history.ready = true;
	history.pushState(null, document.title, this.href);			
	return false;
  });

// -------------------------------------------------------------------------------
// FUNCTIONS TO GET DATA FOR SELECTED RELATIONSHIP
// -------------------------------------------------------------------------------	

$(".relationship_thumb_title a, .relationship_thumb_main a").live('click',function(){
				
	// show message
	show_progress_message("loading relationship data");
	
	// history management
	window.history.ready = true;
	history.pushState(null, document.title, this.href);	

	$("#title_filler_text").hide();
	
});

// -------------------------------------------------------------------------------
// DISPLAYING AND HIDING THE MODAL WINDOW FOR ADDING NEW RELATIONSHIPS
// -------------------------------------------------------------------------------                                                                      
	$(".relationship_addnew .poplight").live('click',function(){
		initialize_addNew();
		$("#modal_form").toggle();		
	});
	
	$('.btn_close').live('click', function(){
		close_addNew();
	});

// -------------------------------------------------------------------------------
// SETTING THE VALUE OF MODAL FORM ACTION AND ISSUE ID WHEN MODAL FORM IS OPENED
// -------------------------------------------------------------------------------

  $(".poplight").live('click', function(){
  
  	var idName = $(this).attr('id');
	
	  // Based on the DOM id, set action value and the text placeholder
	  switch (idName) { 
	  	case 'add_cause_btn':
	  		$("#frm_action").val('C');
	  		$("#query").attr('placeholder', 'Add a Cause of ' + issueTitle)
	  		break;
	  	case 'add_effect_btn':
	  		$("#frm_action").val('E');
	  		$("#query").attr('placeholder', 'Add an Effect of ' + issueTitle); 
	  		break;
	  	case 'add_inhibitor_btn':
	  		$("#frm_action").val('I');
	  		$("#query").attr('placeholder', 'Add something that reduces ' + issueTitle); 
	  		break;
	  	case 'add_inhibited_btn':
	  		$("#frm_action").val('R');
	  		$("#query").attr('placeholder', 'Add something reduced by ' + issueTitle); 
	  		break;
	  	case 'add_superset_btn':
	  		$("#frm_action").val('P');
	  		$("#query").attr('placeholder', 'Add a Superset of ' + issueTitle);
	  		break;
	  	case 'add_subset_btn':
	  		$("#frm_action").val('S');
	  		$("#query").attr('placeholder', 'Add a Subset of ' + issueTitle);
	  		break;
	  }
  		
  	// Set the value of issue ID	
  	$("#frm_type_id").val(idofthisIssue);
    
  });

// -------------------------------------------------------------------------------
// MODAL-DIV SHOW 
// -------------------------------------------------------------------------------  
  //When you click on a link with class of poplight and the href starts with a # 
  $('a.popup[href^=#]').live('click', function() {

	  var popID = $(this).attr('rel'); //Get Popup Name
	  var popURL = $(this).attr('href'); //Get Popup href to define size
	
	  //Pull Query & Variables from href URL
	  var query= popURL.split('?');
	  var dim= query[1].split('&');
	  var popWidth = dim[0].split('=')[1]; //Gets the first query string value
	
	  //Fade in the Popup and add close button
	  $('#' + popID).fadeIn().css({ 'width': Number( popWidth ) }).prepend('<a href="#" class="close"><div class="btn_close" title="Close Window"></div>');
	
	  //Define margin for center alignment (vertical   horizontal) - we add 80px to the height/width to accomodate for the padding  and border width defined in the css
	  var popMargTop = ($('#' + popID).height() + 80) / 2;
	  var popMargLeft = ($('#' + popID).width() + 80) / 2;

	  //Apply Margin to Popup
	  $('#' + popID).css({
	  	'margin-top' : -popMargTop,
	  	'margin-left' : -popMargLeft
	  });

	  //Fade in Background
	  $('body').append('<div id="fade"></div>'); //Add the fade layer to bottom of the body tag.
	  $('#fade').css({'filter' : 'alpha(opacity=80)'}).fadeIn(); //Fade in the fade layer - .css({'filter' : 'alpha(opacity=80)'}) is used to fix the IE Bug on fading transparencies 
	
	  return false;
  });

// -------------------------------------------------------------------------------
// MODAL-DIV HIDE   
// ------------------------------------------------------------------------------- 
  //Close Popups and Fade Layer When clicking on the close or fade layer...
  $('a.close, #fade').live('click', function() {
  	$('#fade , .popup_block').fadeOut(function() {
	  	$('#fade, a.close').remove();  //fade them both out
	  	$('#image_preview1,#image_preview2,#image_preview3').removeAttr('style');
	  	$('#text_holder ').html('');
	  	$('#title_holder').html('');
	  	$('#text_preview').removeAttr('style');
		$("#wait").empty();
	  	$('#form_container').css("display", "none");
	  	$("#query").val(''); 
	  	$("#confirm_popup").fadeOut('slow');    
	  	href_carrier = '';
  	});
  	return false;
  });

// -------------------------------------------------------------------------------
// RELATIONSHIP DELETE FUNCTIONS
// -------------------------------------------------------------------------------
    window.confirm = false;
    var href_carrier = '';
      
  $(".del-relation").live('click', function() {
  	var title = "Delete relation?"
  	var msg = "Are you sure you want to remove this relationship?"
  	href_carrier = $(this).attr('href');
  	showPopup(title, msg);
  
  return false;      
  
  });

// -------------------------------------------------------------------------------
// FUNCTION TO DISPLAY THE CONFIRMATION POPUP
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
// FUNCTION TO DELETE RELATIONSHIP IF YES WAS CLICKED
// -------------------------------------------------------------------------------
  $("#confirm_yes").live('click', function() {
  	$("#confirm_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
	$.post(href_carrier, {_method:'delete'}, null, "script");
  });

// -------------------------------------------------------------------------------
// FUNCTION TO REMOVE MODAL IF USER CANCELED DELETION
// -------------------------------------------------------------------------------	
  $("#confirm_cancel").live('click',function() {
	  $('#fade').remove();
  	  $("#confirm_popup").fadeOut('slow');    
  	  href_carrier = '';
  });

// -------------------------------------------------------------------------------
// SHOW SPINNER ON REFERENCE FORM and COMMENTS FORM SUBMISSION
// -------------------------------------------------------------------------------	
  $('#reference_collector').live('click', function(e){
  	if ($("#ref_content_field").val().length == 0)
  		{e.preventDefault();}
  	else
  		{ $("#references_wait").html('<img border="0" src="/images/system/spinnerf6.gif" width="22px"/>');}
  });	

  $('#comment_collector').live('click', function(e){
	if ($("#com_content_field").val().length == 0)
  		{e.preventDefault();}
  	else
  		{$("#comments_wait").html('<img border="0" src="/images/system/spinnerf6.gif" width="22px"/>');}
  });


// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// A D D    N E W    R E L A T I O N S H I P     F U N C T I O N S 
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	

// -------------------------------------------------------------------------------
// ARROW KEY NAVIGATION FOR THE MODAL
// -------------------------------------------------------------------------------  
  window.displayBoxIndex = -1;
  
  // Arrow keys pressed while being within the Query Box
  $("#query").keyup(function(e) 
  	{
	  if ($.inArray(e.keyCode, ignore_keys_array) == -1){
  		displayBoxIndex = -1;}
	  if (e.keyCode == 40){  
	  	Navigate(1);}
	  if(e.keyCode==38){
	  	Navigate(-1);}
	  if (e.keyCode == 13){
		  $("#query").val($(".suggestion").eq(displayBoxIndex).html());
		  $("#results").empty();
		  displayBoxIndex = -1;
		  start_populating_wikipedia_content();
  	}
  });
                   
  var Navigate = function(diff) {
  	displayBoxIndex += diff;
  	var oBoxCollection = $(".suggestion");
  	if (displayBoxIndex >= oBoxCollection.length)
  		displayBoxIndex = 0;
  	if (displayBoxIndex < 0)
  		displayBoxIndex = oBoxCollection.length - 1;
  	var elem_class = "suggestion_hover";
  	oBoxCollection.removeClass(elem_class).eq(displayBoxIndex).addClass(elem_class);
  }

  $(".suggestion").live('mouseover', function(){
	  displayBoxIndex = $(this).index();
	  var elem_class = "suggestion_hover";
	  var oBoxCollection = $(".suggestion");
	  oBoxCollection.removeClass(elem_class).eq(displayBoxIndex).addClass(elem_class);  
  });  

// ------------------------------------------------------------------------------- 
// FUNCTIONS CALLING MEDIAWIKI API
// -------------------------------------------------------------------------------   
  
	  var url='http://en.wikipedia.org/w/api.php?action=opensearch&search=';
	  var url_query='http://en.wikipedia.org/w/api.php?format=json&action=query&list=search&srsearch=';
	  var url_google_img = 'http://ajax.googleapis.com/ajax/services/search/images?rsz=large&start=0&v=1.0&q=';
	  var query;
	  var arr_length = 0;
	  var search_results = [];
	  var ignore_keys_array = [18,20,17,40,35,13,27,36,45,37,93,91,34,33,39,16,9,38];
	  var mouse_is_inside = false;
	  var url_img_name = 'http://en.wikipedia.org/w/api.php?action=parse&prop=text&section=0&redirects&format=json&page=';
	  var img_src = '';
	  var text_preview = '';
	  var title_holder = '';
	  // Variables to store form field values for Submit:
	  var form_title = '';
	  var form_descr = '';
	  var form_url = '';
	  var form_image = '';  

// -------------------------------------------------------------------------------   
// MONITORING THE KEYUP ACTION ON THE QUERY TEXTBOX 
// ------------------------------------------------------------------------------- 
  $('#query').bind('keyup', function(e){
	  
	  //  Get value of query from the textbox			
	  query=$("#query").val();
	  if (query.trim() =='' || e.keyCode == 27){
	  	$("#results").empty(); }
	
	  //  If the user types in something and it is a valid key	
	  if (query.trim() != '' && ($.inArray(e.keyCode, ignore_keys_array) == -1) ){
  
		  //  Clear the suggestions
		  $("#results").empty();  
		  //  Initialize the suggestion box with a spinner		
		  $("#results").append('<img border="0" src="/images/system/spinnerf6.gif" class="result-spinner"  />');
		  //  Talk to mediawiki API to fetch suggestions 
		  $.getJSON(url_query+encodeURIComponent(query)+'&callback=?',function(data){
		  	  
			  //  Limiting the suggestions to a maximum of 10
			  if (data.query.search.length <= 4) {
			  	arr_length = data.query.search.length - 1;
			  } else {
			  	arr_length = 4;
			  }
  
			  //  Clear the suggestions
			  $("#results").empty();
  
			  //  Loop through first 5 (maximum) suggestions and show 'em
			  for(var i = 0; i<=arr_length; i++){
			  	$("#results").append('<div class="suggestion" >'+data.query.search[i].title+'</div>');
  			  }   //  End of for loop
  		  }); //  End of getJSON function
  	   }  //  End of If structure
	}); // End of keyUp function 

// -------------------------------------------------------------------------------
// GET QUERY FROM SEARCH-BOX
// -------------------------------------------------------------------------------
  $('.suggestion').live('click',function(){
	  $("#query").val($(this).html()); 
	  $("#results").empty();
	  displayBoxIndex = -1;
	  start_populating_wikipedia_content();
  });

// -------------------------------------------------------------------------------
// RETRIEVE CONTENT FROM WIKIPEDIA
// -------------------------------------------------------------------------------  
  $("#btn_preview").click(function(){
	  start_populating_wikipedia_content();
  });

	function start_populating_wikipedia_content(){
	  if ($("#query").val().trim()){
		  $("#results").empty();
		  $("#title_holder").html('');
		  // hide the save button
		  $('#form_container').css("display", "none");
		  // replace HTML of target Div
		  $('#text_holder ').html('');
		  $('#text_preview').removeAttr('style'); 
		  // show dummy image for image
		  $('#image_preview1, #image_preview2, #image_preview3, .check_clicked, .check_empty, .checkmsg').removeAttr('style');
		  parseJSON();
		  $("#results").empty();
	  }		
	}

// -------------------------------------------------------------------------------
// PARSE THE RECEIVED JSON CONTENT
// -------------------------------------------------------------------------------
  function parseJSON() {
// Show the message
	  show_progress_message("loading content from Wikipedia");   	
	  // create the json url
	  var queryRaw = $("#query").val()
	  var queryEncoded = encodeURIComponent(queryRaw);
	  var jsonData = (url_img_name + queryEncoded + "&callback=?")  
  
	  // parse the json
	  $.getJSON(jsonData, function (data) {
	  	// call the getJson function
	  	getContent(data);    
	  
	  });
	 }
  
// -------------------------------------------------------------------------------  
// READ THE PARSED JSON FOR CONTENT			
// -------------------------------------------------------------------------------  		
  function getContent(JData) {
	
	if (JData !== undefined && JData.parse !== undefined) {

      var Jval = JData.parse.text["*"];
	  	//  populate the description text
	  	text_preview = $(Jval.replace(/<p><br \/><\/p>/gi,'')).filter('p:first').text().replace(/\[\d+\]/gi,'');
	  
		  //  Throw error if no text was received
		  if(text_preview == ''){
		  	text_preview = "No data! Please try a different keyword."
  
	  	  //  If the search was successful - 
	  	} else {
	  		$("#title_holder").html(JData.parse.title);
  
		  	// shorten if beyond limit
		  	if(text_preview.length > 450){text_preview = text_preview.substring(0, 450) + '...';}
			  	// replace HTML of target Div
			  	$('#text_holder ').html(text_preview);
			  	$('#text_preview').css({'background-image':'none','height':'auto'});   
			  	form_descr = $("#text_holder ").html();
			  	// show the form 
			  	$("#form_container").css("display", "block");

			  	// find the image from Json
			  	img_src = $(Jval).find('img.thumbimage').attr('src');  
  
			  	// if image not found from wikipedia, get it from google
			  	if (img_src == null){

				  // retrieve JSON from google images search and pull the url for first image result
				  $.getJSON(url_google_img+encodeURIComponent($("#query").val())+'&callback=?', function(data) {
					  $.each(data.responseData.results, function(i,item){
					  	// replace HTML of target Div
					  	$('#image_preview' + (i+1)).css({'background-image': 'url("'+item.tbUrl+'")'});
					  	$('#image_preview2, #image_preview3, .check_empty, .checkmsg').show();
					  	//form_image = $('#image_preview1').html();
					  	if ( i == 2 ) return false;
					  	});  
				  });
  				  // Select the first image option by default	
  				  $(".check_clicked:first").show();
  
			  	// if the image was found from WIKIPEDIA itself, then just go ahead and use that.
			  	} else {
				  // replace HTML of target Div 
				  $('#image_preview1').css({'background-image': 'url("'+img_src+'")'});
				  form_image = $("#image_preview1 img:first").attr("src");
  
  				}  // END of If structure (checking for Image Success from Wikipedia)	  
  			}  // END of If structure (checking for Text Success from Wikipedia)
		  // remove progress message
		  hide_progress_message();
  		}  // END of If structure (checking if this is a valid object) 
  		else { show_error_message("no data! Please try a different keyword.") }	  			
  }  // END of function  

// -------------------------------------------------------------------------------
// WHEN THE USER HITS CREATE IN THE CREATE NEW RELATIONSHIP DIALOG:
// -------------------------------------------------------------------------------
  $("#val_collector").live('click', function(){
	  // Call the function to show the spinner and make space if required
	  show_progress_message("creating relationship")
	  // Gather the values for the Form submission
	  valueCollect();
	  // Initialize the Modal
	  initialize_addNew();
	  close_addNew();
  	  // S U B M I T    T H E    F O R M
  	  ("form#relationship_form").submit();
	  return false;
  });

// -------------------------------------------------------------------------------
// GATHER THE VALUES FOR THE FORM SUBMISSION
// -------------------------------------------------------------------------------
  function valueCollect() {
	
	// 1.   I M A G E   U R L
  	if ($(".check_empty").is(":visible")) // If the radio buttons are shown (images coming from google)
  		{	// Filter out the radio button that was clicked
  			var clickedDiv = $(".check_clicked").filter(function() {
			return $(this).is(":visible")	
         });
  			// The Selected image Div
  			var selectedImgDiv = clickedDiv.parents(".img_prev")
  			$("#frm_img_url").val(extractUrl(selectedImgDiv.css("background-image")));
  		}
  	else	// If the image came from Wikipedia just get it from the first Div
  		{	$("#frm_img_url").val(extractUrl($("#image_preview1").css("background-image")));}
  
  	// 2.   W I K I P E D I A    U R L
  	$("#frm_wiki_url").val("http://en.wikipedia.org/wiki/" + ($("#title_holder").html().trim()).split(' ').join('_')); 
  	
  	// 3.   W I K I P E D I A    D E S C R I P T I O N 
  	$("#frm_descr").val(form_descr);
  	
  	// 4.   W I K I P E D I A    T I T L E 
	$("#frm_title").val($("#title_holder").html().trim());
  	
  }

// -------------------------------------------------------------------------------
// EXTRACT THE BACKGROUND-IMAGE URL FROM THE DIV
// -------------------------------------------------------------------------------
	function extractUrl(input)
  		{
  			return input.replace(/"/g,"").replace(/url\(|\)$/ig, "");
  		}

// -------------------------------------------------------------------------------
// FUNCTIONS TO INITIALIZE AND TOGGLE ADD_NEW MODAL
// -------------------------------------------------------------------------------	
	function close_addNew() {
	  $("#modal_form").removeAttr('style');			
	}
	
	function initialize_addNew(){
	  $('#image_preview1, #image_preview2, #image_preview3, .check_clicked, .check_empty, .checkmsg').removeAttr('style');
	  $('#text_holder ').html('');
	  $('#title_holder').html('');
	  $('#text_preview').removeAttr('style');
	  $("#wait").empty();
	  $('#form_container').css("display", "none");
	  $("#query").val('');
	  $("#frm_is_suggestion").val(''); 		
	}

// -------------------------------------------------------------------------------
// SELECT THE IMAGE FROM THE GOOGLE OPTIONS
// -------------------------------------------------------------------------------
	$(".check_empty").click(function(){
		$('.check_clicked').removeAttr('style');
		$(this).siblings('.check_clicked').show();
	});

// -------------------------------------------------------------------------------
// CLOSE SUGGESTIONS IF CLICKED ELSEWHERE
// -------------------------------------------------------------------------------	
  $('#results, #query').hover(function(){ 
	  mouse_is_inside=true; 
	  }, function(){ 
	  mouse_is_inside=false; 
  });

  $("body").mouseup(function(){ 
	  if(! mouse_is_inside) {
		  $("#results").empty();
		  $("#wait").empty(); 
		  displayBoxIndex = -1; }
  });

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

// -------------------------------------------------------------------------------
// FUNCTION TO RETRIEVE IMAGE OPTIONS FROM GOOGLE 
// -------------------------------------------------------------------------------

	$('.btn_image_edit').live('click', function(){
	  // Default inner HTML		
	  $(this).html('Edit Issue image');	
	  // Display the Modal for image options
	  $(".edit_image_modal").toggle();
	  
	  // If the form was opened:
	  if ($(".edit_image_modal").is(":visible")){
		  // retrieve JSON from google images search and pull the url for first image result
		  $.getJSON(url_google_img+encodeURIComponent($(".main_thumb_title").text())+'&callback=?', function(data) {
			  $.each(data.responseData.results, function(i,item){
			  	// replace HTML of target Div
			  	$('#image_edit_option' + (i+1)).css({'background-image': 'url("'+item.tbUrl+'")'});
			  	$('.check_empty_edit').show();
			  	if ( i == 2 ) return false;
			  	  // Show an up arrow	
				  				  	
			  	});  
			  // Select the first image option by default	
			  $(".image_edit_container_wait").hide();
			  $('.btn_image_edit').html('Edit Issue image &#9650;');
			  $(".image_edit_container").show();
			  $(".check_clicked_edit:first").show();
			  // Set the background of this first selected as the default value
			  $("#frm_img_update").val(extractUrl($("#image_edit_option1").css("background-image")))

		  });
		}
	});

// -------------------------------------------------------------------------------
// SET THE VALUE OF THE FIELD IN IMAGE UPDATE FORM BASED ON SELECTION
// -------------------------------------------------------------------------------
	$(".check_empty_edit").live('click', function(){
		$('.check_clicked_edit').removeAttr('style');
		// Show selection
		$(this).siblings('.check_clicked_edit').show();
		// Update field value in the form accordingly
		$("#frm_img_update").val(extractUrl($(this).parents(".image_edit_option").css("background-image")))
	});

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// S U G G E S T I O N S     M E D I A W I K I     D A T A 
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

	var queryEncoded_sugg = ""
	var suggestion_thumb_to_update
	
	$(".suggestion_thumb").live('click', function(){
		// Opacity changes to highlight the one that is clicked
		$('.relationship_thumb').not($(this)).animate({'opacity': '0.3'});
		$(this).animate({'opacity': '1'});
		
		// Hide Linkout class if shown anywhere 		
		$(".issue_linkout").removeAttr('style');
		
		// Remove any existing stle attributes/backgrounds from the thumbnails
		$(".relationship_thumb_suggestion").removeAttr('style').removeClass('suggestion_selected');		
		$(".relationship_thumb").removeClass('selected_relationship_thumb');
		$(".suggestion_thumb").removeClass('selected_suggestion_thumb');
		$(this).addClass('selected_suggestion_thumb');

		// initialize the relationship
		$("#get_rel_issueid_input").val($("#issue_id_store").text().trim());
		// Show the message
		show_progress_message("loading content from Wikipedia")
	 	
	 	// DOM object for the thumbnail that will be updated
	 	suggestion_thumb_to_update = $(this).children(".relationship_thumb_suggestion")
	 	
	 	// Form query
	 	var queryRaw_sugg = $(this).children(".relationship_suggestion_title").text().trim()
	    var queryEncoded_sugg = encodeURIComponent(queryRaw_sugg);
	    var jsonData_sugg = (url_img_name + queryEncoded_sugg + "&callback=?") 		
		
		// Call ParseJSON fn
		parseJSON_sugg(jsonData_sugg);
	});

// -------------------------------------------------------------------------------
// PARSE THE RECEIVED JSON CONTENT
// -------------------------------------------------------------------------------
  function parseJSON_sugg(jsonData_sugg) {
	// parse the json
	  $.getJSON(jsonData_sugg, function (data_sugg) {
	  	// call the getJson function
	  	getContent_sugg(data_sugg);

	  	// trigger the mouseout function on suggestion_thumb
	  	$(".suggestion_thumb:not(.selected_suggestion_thumb)").trigger('mouseout');
	  });
	 }
  
// -------------------------------------------------------------------------------  
// READ THE PARSED JSON FOR CONTENT			
// -------------------------------------------------------------------------------  		
  function getContent_sugg(JData_sugg) {

	if (JData_sugg !== undefined && JData_sugg.parse !== undefined) {

      var Jval_sugg = JData_sugg.parse.text["*"];
	  	//  populate the description text
	  	text_preview = $(Jval_sugg.replace(/<p><br \/><\/p>/gi,'')).filter('p:first').text().replace(/\[\d+\]/gi,'');
	  
		  //  Throw error if no text was received
		  if(text_preview == ''){
		  	text_preview = "No data! Please try a different keyword."
  
	  	  //  If the search was successful - 
	  	} else {
	  		if(text_preview.length > 450){text_preview = text_preview.substring(0, 450) + '...';}
	  		
	  		// Make the Causal sentence 
	  		$("#title_issue").html($(".main_thumb_title").text().trim());
	  		// call function to identify what should be the causal sentence?
	  		write_causal_sentence($(".central_causality_container").text().trim())
			$("#title_relationship").html(JData_sugg.parse.title).show();
			// Hide stuff
	    	$("#title_relationship_hover").html('').hide();	
			$("#title_dynamic_text").removeAttr('style');
		  	
		  	// Hide the Divs that are not required
			$(".relation_controls, .relation_discussion").hide();
			
			// Show the Divs and replace HTML
			$("#system_generated").show();
			$('#relationship_title_dynamic').html(JData_sugg.parse.title + ":");
			$('.rationale_headers:first').html('Wikipedia Description');
			$('#relationship_descr_dynamic').html(text_preview);  
			$('#relationship_linkout_dynamic').html('<img class="linkout" src="/images/system/linkout.png">')
			var linkSrc = "http://en.wikipedia.org/wiki/" + (JData_sugg.parse.title).split(' ').join('_');
			$('#relationship_link_dynamic').html('<a href="' + linkSrc + '" target="_blank">more on Wikipedia</a>');
			  	
			// find the image from Json
			img_src = $(Jval_sugg).find('img.thumbimage').attr('src');  
			
			// if image not found from wikipedia, get it from google
			if (img_src == null){
					
				  var google_imgquery = encodeURIComponent(JData_sugg.parse.title)
				  // retrieve JSON from google images search and pull the url for first image result
				  $.getJSON(url_google_img + google_imgquery + '&callback=?', function(data_sugg) {
					  $.each(data_sugg.responseData.results, function(i,item){
					  	// replace HTML of target Div
					  	suggestion_thumb_to_update.css({'background-image': 'url("'+item.tbUrl+'")'}).addClass('suggestion_selected');
					  	if ( i == 1 ) return false;
					  	});  
					 // Show the accept or reject buttons once images are loaded
					 suggestion_thumb_to_update.siblings(".issue_linkout").fadeIn(); 	
				  });
  
			  	// if the image was found from WIKIPEDIA itself, then just go ahead and use that.
			  	} else {
				  // replace HTML of target Div 
				  suggestion_thumb_to_update.css({'background-image': 'url("'+img_src+'")'}).addClass('suggestion_selected');
				 // Show the accept or reject buttons once images are loaded
				 suggestion_thumb_to_update.siblings(".issue_linkout").fadeIn();  
  				
  				}  // END of If structure (checking for Image Success from Wikipedia)	  
  			}  // END of If structure (checking for Text Success from Wikipedia)
		  // remove progress message
		  hide_progress_message();
  		}  // END of If structure (checking if this is a valid object) 
  		else { 
  			$("#title_relationship").html('');
  			show_error_message("no data! Would you like to reject this suggestion?") 
			// Show the accept or reject buttons once images are loaded
			suggestion_thumb_to_update.siblings(".suggestion_reject").fadeIn(); 
  		}	  			
  }  // END of function


// -------------------------------------------------------------------------------  
// WRITING THE CORRESPONDING CAUSAL SENTENCE FOR SUGGESTIONS		
// -------------------------------------------------------------------------------
	function write_causal_sentence(current_sentence){

	switch (current_sentence) { 
	  case 'is caused by':
		$("#title_causality").html('may be caused by')
		$("#frm_action").val('C')
	  break;
	  case 'causes':
		$("#title_causality").html('may cause')
	  	$("#frm_action").val('E')
	  break;
	  case 'is reduced by':
		$("#title_causality").html('may be reduced by')
		$("#frm_action").val('I')
	  break;
	  case 'reduces':
		$("#title_causality").html('may reduce')
		$("#frm_action").val('R')
	  break;
	  case 'includes':
		$("#title_causality").html('may include')
		$("#frm_action").val('S')
	  break;
	  case 'is a part of':
		$("#title_causality").html('may be a part of')
		$("#frm_action").val('P')
	  break;
	  }
		
		$("#title_causality").addClass('suggested_causality')
		
	}

// -------------------------------------------------------------------------------
// ACCEPT SUGGESTION
// -------------------------------------------------------------------------------
	$(".suggestion_accept").live('click', function(){
	  	// Call the function to show the spinner and make space if required
	  	show_progress_message("confirming suggestion as accepted")
		// collect the form values
		sugg_valueCollect();
		// Submit the form
		$.post($("#new_issue").attr("action"), $("#new_issue").serialize(), null, "script");

		return false;
	});

	function sugg_valueCollect(){
		// 1.   I M A G E   U R L
	  	$("#frm_img_url").val(extractUrl(suggestion_thumb_to_update.css("background-image")));
	  	// 2.   W I K I P E D I A    U R L
	  	$("#frm_wiki_url").val($("#relationship_link_dynamic a").attr('href')); 
	  	// 3.   W I K I P E D I A    D E S C R I P T I O N 
	  	$("#frm_descr").val($("#relationship_descr_dynamic").text().trim());
	  	// 4.   W I K I P E D I A    T I T L E 
	  	var title_raw    = $("#relationship_title_dynamic").text().trim()
	  	var title_sliced = title_raw.substring(0, title_raw.length - 1)
		$("#frm_title").val(title_sliced);
		// 5.   C A U S A L I T Y    T Y P E
		// ALREADY POPULATED ABOVE
		// 6.   I S S U E    I D
		$("#frm_type_id").val($("#issue_id_store").text().trim());
		// P A S S    S U G G E S T I O N    I D    P A R A M
		$("#frm_is_suggestion").val(suggestion_thumb_to_update.siblings(".suggestion_id_store").text().trim())
	
	}
	
// -------------------------------------------------------------------------------
// RETURN FALSE ON CLICK OF REJECT SUGGESTION
// -------------------------------------------------------------------------------
	$(".suggestion_reject a").live('click', function(){
	  	// Call the function to show the spinner and make space if required
	  	show_progress_message("removing suggestion")		
		return false;
	})

// -------------------------------------------------------------------------------
// FUNCTIONS FOR CALLING VARIOUS TOOLTIPS
// -------------------------------------------------------------------------------

  var tooltipMsg = {
	   'sugg_accept': 'Accept this suggestion',
	   'sugg_reject': 'Reject this suggestion',
	   'rel_linkout': 'Go to this issue',
	   'grav_you'	: 'You'
  };

  // TOOL-TIP FOR SUGGESTION ACCEPT
  $(".suggestion_accept").live('mouseover', function(){
	  tooltip_caller = $(this);
	  tooltip_text   = tooltipMsg.sugg_accept;
	  showTooltip(tooltip_caller, tooltip_text);
  });

  // TOOL-TIP FOR SUGGESTION REJECT
  $(".suggestion_reject").live('mouseover', function(){
	  tooltip_caller = $(this);
	  tooltip_text   = tooltipMsg.sugg_reject;
	  showTooltip(tooltip_caller, tooltip_text);
  });

  // TOOL-TIP FOR SUGGESTION REJECT
  $(".issue_linkout:not(.suggestion_reject, .suggestion_accept)").live('mouseover', function(){
	  tooltip_caller = $(this);
	  tooltip_text   = tooltipMsg.rel_linkout;
	  showTooltip(tooltip_caller, tooltip_text);
  });

  // TOOL-TIP FOR SUGGESTION REJECT
  $("a.gravatar_vote, a.gravatar_anchor,.reference_gravatar, .comment_gravatar").live('mouseover', function(){
	  tooltip_caller = $(this);
	  tooltip_text   = tooltip_caller.attr('title');
	  tooltip_caller.data("title", $(this).attr("title"));
	  tooltip_caller.removeAttr("title");
	  showTooltip(tooltip_caller, tooltip_text);
  });


  $(".issue_linkout").live("mouseleave", function(){
	  hideTooltip();
  });

  $("a.gravatar_vote, a.gravatar_anchor, .reference_gravatar, .comment_gravatar").live('mouseleave', function(){
  	  $(this).attr("title", $(this).data("title"));
  	  hideTooltip();
  });


// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||