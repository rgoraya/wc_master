$(function() { 
 
$("#order_form").click(function() {
	$("#order_form_select").change(function(){
		$.get($("#order_form_select").action, $("#order_form_select").serialize(), null, "script");		
	});
	
	    return false;
	});

});
