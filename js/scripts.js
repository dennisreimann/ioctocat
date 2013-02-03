// redirect to official page from GitHub pages
if (window.location.host == "dennisreimann.github.com") {
  window.location = 'http://ioctocat.com';
}

$(document).ready(function(){
	// Show the first screenshot
	$("#screenshots li:first").toggle();
	// Switch to the next screenshot on click
	$("#screenshots").click(function(event){
		$("#screenshots li").each(function(){
			if ($(this).is(":visible")) {
				$(this).hide();
				var next = $(this).next().length ? $(this).next() : $("#screenshots li:first");
				next.show();
				return false;
			}
		});
	});
 });
