/*$('#hero-text h1').textfill();*/

$('.tilt').tilt({
   perspective: 1200,
   speed: 500,
   scale: 1.01
});

$('.link').each(function() {
   var go = $(this).find('a').attr('href');
   if (go == undefined) {
      $(this).toggleClass("link");
   } else {
      $(this).click(function() {
         window.location = go;
         return false;
      });
   };
});

$(".link").hover(function() {
   $(this).find('a').toggleClass("hover");
});
