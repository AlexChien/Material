// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
	resetInfo();
	nav_toggle();
});

function resetInfo() {
	window.setTimeout(
		function() {
			$('#notice,#error,#warn').slideUp('slow');
	}, 5000);
}

function nav_toggle() {
	$('.leftnav_header').click(function(e){
  		var val = $(this).attr("value");
  		$("#leftnav_"+val).toggle("slow");
  	})
}