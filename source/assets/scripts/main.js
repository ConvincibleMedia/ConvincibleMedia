$(document).ready(function(){

/* Tilt Effects */
$('.tilt').tilt({
   perspective: 1200,
   speed: 500,
   scale: 1.01
});

/* Links */
$('.link').each(function() {
   var go = $(this).find('a').attr('href');
   if (go == undefined) {
      $(this).toggleClass("link");
   } else {
      $(this).click(function(e) {
         window.location = go;
         return false;
      });
   };
});
$(".link").hover(function() {
   $(this).find('a').toggleClass("hover");
});

/* Match Height */
$(function() {
	$('.grid').matchHeight({
        property: 'min-height'
    });
});
$.fn.matchHeight._throttle = 500;

// Show these items only if JS runs
$('.js-show').removeClass('js-show');

});
