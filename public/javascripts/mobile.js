// iWebKit functions.
var iWebkit;if(!iWebkit){iWebkit=window.onload=function(){function fullscreen(){var a=document.getElementsByTagName("a");for(var i=0;i<a.length;i++){if(a[i].className.match("noeffect")){}else{a[i].onclick=function(){window.location=this.getAttribute("href");return false}}}}function hideURLbar(){window.scrollTo(0,0.9)}iWebkit.init=function(){fullscreen();hideURLbar()};iWebkit.init()}}

// Our functions.
jQuery(document).ready(function() {
    jQuery("ul.arrows li a").append("<span class='arrow'></span>");
    jQuery("a[href=#info]").click(function(e) {
	e.preventDefault();
	jQuery("#info").toggle();
	return false;
    });
});