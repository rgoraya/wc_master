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


	$(".relationship_thumb_title a, .relationship_thumb_main a").live('click',function(){
		
		$(this).parents('.relationship_thumb').animate({'opacity': '1'});
		$('.relationship_thumb').not($(this).parents('.relationship_thumb')).animate({'opacity': '0.3'});
					
		$("#relationship_wait").html('<img border="0" src="/images/system/spinnerf6.gif"/>');
  		
  		var relationship_id = $(this).parents('.relationship_thumb').children('.relationship_id_store').html().trim();
		
		$("#title_filler_text").hide();
		
		close_addNew();
		$('.del-relation').attr('href', "../relationships/" + relationship_id);
		
		$(".issue_linkout").removeAttr('style');
		$(this).parents('.relationship_thumb').children(".issue_linkout").fadeIn();
	
		return false;
	});
	

	$(".relationship_addnew .poplight").live('click',function(){
		initialize_addNew();
		$("#modal_form").toggle();		
	});
	
	$('.btn_close, .relationship_partial_toggle').live('click', function(){
		close_addNew();
		$("#modal_form").hide();
	});


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

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// A D D    N E W    R E L A T I O N S H I P     F U N C T I O N S 
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	

// -------------------------------------------------------------------------------
// A R R O W    K E Y    N A V I G A T I O N    F O R    T H E    M O D A L
// -------------------------------------------------------------------------------  
  window.displayBoxIndex = -1;
  
  // Arrow keys pressed while being within the Query Box
  $("#query").keyup(function(e) 
  	{
	  if (e.keyCode == 40){  
	  	Navigate(1);}
	  if(e.keyCode==38){
	  	Navigate(-1);}
	  if (e.keyCode == 13){
		  $("#query").val($(".suggestion").eq(displayBoxIndex).html());
		  $("#results").empty();
		  displayBoxIndex = -1;
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
// F U N C T I O N S    C A L L I N G    M E D I A W I K I    A P I
// -------------------------------------------------------------------------------   
  
	  var url='http://en.wikipedia.org/w/api.php?action=opensearch&search=';
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
// Monitoring the keyUp action on the query textbox 
// ------------------------------------------------------------------------------- 
  $('#query').bind('keyup', function(e){
	  
	  //  Get value of query from the textbox			
	  query=$("#query").val();
	  if (query =='' || e.keyCode == 27){
	  	$("#results").empty(); }
	
	  //  If the user types in something and it is a valid key	
	  if (query != '' && ($.inArray(e.keyCode, ignore_keys_array) == -1) ){
  
		  //  Clear the suggestions
		  $("#results").empty();  
		  //  Initialize the suggestion box with a spinner		
		  $("#results").append('<img border="0" src="/images/system/spinner.gif" class="result-spinner"  />');
		  //  Talk to mediawiki API to fetch suggestions 
		  $.getJSON(url+encodeURIComponent(query)+'&callback=?',function(data){
		  	  
		  	  // Populate Array of search results
			  search_results = data[1];
			  //  Limiting the suggestions to a maximum of 5
			  if (search_results.length <= 4) {
			  	arr_length = search_results.length - 1;
			  } else {
			  	arr_length = 4;
			  }
  
			  //  Clear the suggestions
			  $("#results").empty();
  
			  //  Loop through first 5 (maximum) suggestions and show 'em
			  for(var i = 0; i<=arr_length; i++){
			  	$("#results").append('<div class="suggestion" >'+search_results[i]+'</div>');
  			  }   //  End of for loop
  		  }); //  End of getJSON function
  	   }  //  End of If structure
	}); // End of keyUp function 

// -------------------------------------------------------------------------------
// G E T    Q U E R Y    F R O M    S E A R C H - B O X
// -------------------------------------------------------------------------------
  $('.suggestion').live('click',function(){
	  $("#query").val($(this).html()); 
	  $("#results").empty();
	  displayBoxIndex = -1;
  });

// -------------------------------------------------------------------------------
// R E T R I E V E    C O N T E N T    F R O M    W I K I P E D I A
// -------------------------------------------------------------------------------  
  $("#btn_preview").click(function(){
	  if ($("#query").val()){
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
  });

// -------------------------------------------------------------------------------
// P A R S E    T H E    R E C E I V E D    J S O N    C O N T E N T
// -------------------------------------------------------------------------------
  function parseJSON() {
	  // initialize spinner
	  $("#wait").html('<img border="0" src="/images/system/spinnef2f.gif"/>');    	
	  // create the json url
	  var queryRaw = $("#query").val()
	  var queryEncoded = encodeURIComponent(queryRaw).replace('\'','%27').replace('(','%28').replace(')','%29');
	  var jsonData = (url_img_name + queryEncoded + "&callback=?")  
  
	  // parse the json
	  $.getJSON(jsonData, function (data) {
	  	$.each(data, function (key, val) {
	  	// call the getJson function
	  	getJson(val);    
	  });    
	  
	  	// remove spinner
	  	$("#wait").empty();
	  });
	 }
  
// -------------------------------------------------------------------------------  
// R E A D    T H E    P A R S E D    J S O N    F O R    C O N T E N T			
// -------------------------------------------------------------------------------  		
  function getJson(JData) {
   
  	$.each(JData, function (Jkey, Jval) {
  	if (Jval && typeof Jval == "object") {
	  getJson(Jval);    
  	} else {
	  if (Jkey == "title"){
	  	title_holder = Jval;}
	  	//  populate the description text
	  	text_preview = $(Jval.replace(/<p><br \/><\/p>/gi,'')).filter('p:first').text().replace(/\[\d+\]/gi,'');
	  
		  //  Throw error if no text was received
		  if(text_preview == ''){
		  	text_preview = "No data! Please try a different keyword."
  
	  	  //  If the search was successful - 
	  	} else {
	  		$("#title_holder").html(title_holder);
  
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
  		}   // END of If structure (checking for type Object)
  	 }); // END of Each loop
  }  // END of function  


// -------------------------------------------------------------------------------
// WHEN THE USER HITS CREATE IN THE CREATE NEW RELATIONSHIP DIALOG:
// -------------------------------------------------------------------------------
  $("#val_collector").live('click', function(){
	  // Call the function to show the spinner and make space if required
	  showWait_makeSpace();
	  // Gather the values for the Form submission
	  valueCollect();
	  // Initialize the Modal
	  initialize_addNew();
  	  // S U B M I T    T H E    F O R M
  	  ("form#relationship_form").submit();	  
	  return false;
  });

// -------------------------------------------------------------------------------
// Function to show the spinner and make space if required
// -------------------------------------------------------------------------------
	function showWait_makeSpace()
  	{
	  	// Show The Spinner and Hide the none_found message (if shown)
		$('.relationship_addnew_wait').show();
		$('.relationship_none_found').hide();
		
		// if more than 5 relationships are displayed then hide the last one to make space!!
		if ($('.relationship_thumb:visible').length > 5){
	 		$('.relationship_thumb:visible').last().hide();	
		}  
	}

// -------------------------------------------------------------------------------
// Gather the values for the Form submission
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
// Extract the background-image url from the DIV
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
	}

// -------------------------------------------------------------------------------
// SELECT THE IMAGE FROM THE GOOGLE OPTIONS
// -------------------------------------------------------------------------------
	$(".check_empty").click(function(){
		$('.check_clicked').removeAttr('style');
		$(this).siblings('.check_clicked').show();
	});

// -------------------------------------------------------------------------------
// Close suggestions if clicked elsewhere
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
//******************   E N D    O F    D O M    L O A D   ************************
});
// *******************************************************************************
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


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