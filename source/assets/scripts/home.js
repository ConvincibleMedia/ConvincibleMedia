$(document).ready(function(){
	$('#carousel-cta').slick({
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
		zIndex: 999999
	});
	$('#carousel-examples').slick({
		autoplay: true,
		autoplaySpeed: 5000,
		pauseOnHover: true,
		waitForAnimate: true,
		draggable: false,
		adaptiveHeight: true,
		infinite: true,
		slidesToShow: 6,
		slidesToScroll: 2,
		dots: false,
		arrows: false,
		zIndex: 999999,
		responsive: [
			{
				breakpoint: 480,
				settings: {
					slidesToShow: 2,
					slidesToScroll: 1
				}
			},
			{
				breakpoint: 800,
				settings: {
					slidesToShow: 3,
					slidesToScroll: 1
				}
			},
			{
				breakpoint: 1280,
				settings: {
					slidesToShow: 4,
					slidesToScroll: 2
				}
			},
		]
	});
});
