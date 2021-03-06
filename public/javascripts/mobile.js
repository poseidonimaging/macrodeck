// iWebKit functions.
var iWebkit;if(!iWebkit){iWebkit=window.onload=function(){function fullscreen(){var a=document.getElementsByTagName("a");for(var i=0;i<a.length;i++){if(a[i].className.match("noeffect")){}else{a[i].onclick=function(){window.location=this.getAttribute("href");return false}}}}function hideURLbar(){window.scrollTo(0,0.9)}iWebkit.init=function(){fullscreen();hideURLbar()};iWebkit.init()}}

// Our functions.
jQuery(document).ready(function() {
    jQuery("ul.arrows li a").append("<span class='arrow'></span>");
    jQuery("a[href=#info]").click(function(e) {
	e.preventDefault();
	jQuery("#info").slideToggle();
	return false;
    });

    // Check for desktop
    if (jQuery(document).width() > 960) {
	jQuery("span.action a.tel").click(function(e) {
	   e.preventDefault();
	   alert(jQuery("span.action a.tel span").first().text());
	   return false;
	});
    }

    // Hook the next button if possible
    jQuery(".nextbtn a").live('click', function(e) {
	e.preventDefault();

	jQuery.get(jQuery(".nextbtn a").attr("href"), function(data) {
	    jQuery(".nextbtn").replaceWith(data);
	});

	return false;
    });
});