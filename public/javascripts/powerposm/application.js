// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
	resetInfo();
});

function resetInfo() {
	window.setTimeout(
		function() {
			$('#notice,#error,#warn').slideUp('slow');
	}, 5000);
}