/* Javascript for Issue Show page */
$(function() {

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||   A D D    N E W    I S S U E     F U N C T I O N S   |||||||||||||
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
// M O N I T O R I N G    T H E    K E Y U P    O N    S E A R C H F I E L D
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
		  $('.relation_descr').removeAttr('style'); 
		  
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
	  // Show the message
	  show_progress_message("loading content from Wikipedia")    	
	  // create the json url
	  var queryRaw = $("#query").val()
	  var queryEncoded = encodeURIComponent(queryRaw);
	  var jsonData = (url_img_name + queryEncoded + "&callback=?")  
  
	  // parse the json
	  $.getJSON(jsonData, function (data) {
	  	// call the getJson function
	  	getContent(data);    
	  
	  	// remove progress message
	  	hide_progress_message();
	  });
	 }
  
// -------------------------------------------------------------------------------  
// R E A D    T H E    P A R S E D    J S O N    F O R    C O N T E N T			
// -------------------------------------------------------------------------------  		
  function getContent(JData) {

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
  }  // END of function  


// -------------------------------------------------------------------------------
// W H E N    T H E    U S E R    H I T S    C R E A T E
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
// E X T R A C T   T H E    B A C K G R O U N D    I M A G E 
// -------------------------------------------------------------------------------
	function extractUrl(input)
  		{
  			return input.replace(/"/g,"").replace(/url\(|\)$/ig, "");
  		}

// -------------------------------------------------------------------------------
// S E L E C T    T H E    I M A G E    F R O M    G O O G L E    O P T I O N S
// -------------------------------------------------------------------------------
	$(".check_empty").click(function(){
		$('.check_clicked').removeAttr('style');
		$(this).siblings('.check_clicked').show();
	});

// -------------------------------------------------------------------------------
// C L O S E    A U T O C O M P L E T E   I F   C L I C K E D    E L S E W H E R E 
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