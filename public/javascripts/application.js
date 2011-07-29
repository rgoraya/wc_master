$(function() {
  
  $("#issues .pagination a").live("click", function() {
    
	$("#issues #issues_wait").html('<img border="0" src="/images/system/spinner.gif" />');
	$.getScript(this.href);
    
	return false;
  });

});