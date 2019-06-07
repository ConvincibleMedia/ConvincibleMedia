$(document).ready(function(){
	$('.carousel').slick({
		autoplay: true,
		autoplaySpeed: 10000,
		pauseOnHover: true,
		waitForAnimate: true,
		draggable: false,
		adaptiveHeight: true,
		infinite: true,
		slidesToShow: 1,
		dots: false,
		arrows: false,
		zIndex: 999999,
	});
});
