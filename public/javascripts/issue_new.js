/* Javascript for Issue New page */
$(function() {

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||   A D D    N E W    I S S U E     F U N C T I O N S   |||||||||||||
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
 
	  var url='http://en.wikipedia.org/w/api.php?action=opensearch&search='; //opensearch
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
// MONITORING THE KEYUP ON SEARCH FIELD
// ------------------------------------------------------------------------------- 
  $('#query').keyup(function(e){
	  
	  //  Get value of query from the textbox			
	  query = $("#query").val();
	  if (query.trim() == '' || e.keyCode == 27){
	  	$("#results").empty(); }
	
	  //  If the user types in something and it is a valid key	
	  if (query.trim() != '' && ($.inArray(e.keyCode, ignore_keys_array) == -1) ){
  
		  //  Clear the suggestions
		  $("#results").empty();  
		  //  Initialize the suggestion box with a spinner		
		  $("#results").append('<img border="0" src="/images/system/spinnerf6.gif" class="result-spinner"  />');
		  //  Talk to mediawiki API to fetch suggestions 
		  $.getJSON(url_query+encodeURIComponent(query)+'&callback=?',function(data){
		  	  
		  	  // Populate Array of search results
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
		  $(".title").removeAttr('style');
		  // hide the save button
		  $('#form_container').css("display", "none");
		  // replace HTML of target Div
		  $('#text_holder ').html('');
		  $('#text_preview').removeAttr('style');
		  $('.relation_descr').removeAttr('style'); 
		  
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
		  	
		  	show_progress_message = "No data! Please try a different keyword."
  
	  	  //  If the search was successful - 
	  	} else {
	  		$("#title_holder").html(JData.parse.title);
  			$(".title").show();
		  	// shorten if beyond limit
		  	if(text_preview.length > 450){text_preview = text_preview.substring(0, 450) + '...';}
			  	// replace HTML of target Div
			  	$('#text_holder ').html(text_preview);
			  	$('#text_preview').css({'background-image':'none','height':'auto'});   
			  	form_descr = $("#text_holder ").html();
			  	$('.relation_descr').show();
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
// WHEN THE USER HITS CREATE
// -------------------------------------------------------------------------------
  $("#val_collector").live('click', function(){
	  
	  // Show progress message
	  show_progress_message("creating the first node")
	  
	  // Gather the values for the Form submission
	  valueCollect();

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
// EXTRACT THE BACKGROUND IMAGE 
// -------------------------------------------------------------------------------
	function extractUrl(input)
  		{
  			return input.replace(/"/g,"").replace(/url\(|\)$/ig, "");
  		}

// -------------------------------------------------------------------------------
// SELECT THE IMAGE FROM GOOGLE OPTIONS
// -------------------------------------------------------------------------------
	$(".check_empty").click(function(){
		$('.check_clicked').removeAttr('style');
		$(this).siblings('.check_clicked').show();
	});

// -------------------------------------------------------------------------------
// CLOSE AUTOCOMPLETE IF CLICKED ELSEWHERE 
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