var forms = {};

$('form.form').each(function(i, el) {
	var form = $(el);
	var info = $('.form-info', form).first()[0];
	var submit = $('.form-submit', form).last()[0];
	form.data('id', i);
	form.data('info', info);
	form.data('submit', submit);
});

function recaptchaLoad() {
	console.log('Loading reCAPTCHAs...');
	$('.form').each(function(i, el) {
		var form = $(el);
		var captcha = form.find('.g-recaptcha').first()[0];
		var submit = form.data('submit');
		var id = form.data('id');

		widget = grecaptcha.render(captcha, {
			'sitekey': '6Le4racUAAAAAE9dE5yXrtwX0CYuQCqEeN8_joSt',
			'callback': function(token) {
				recaptchaResponse(form[0], token);
			},
			'bind': submit,
			'badge': 'inline',
			'size': 'invisible'
		});
		form.data('grecaptcha-widget', widget);

		console.log('Form ' + id + ': Loaded');

	});
}

function recaptchaResponse(form, token) {
	widget = $(form).data('grecaptcha-widget');
	response = grecaptcha.getResponse(widget);
	if (response) {
		console.log('reCAPTCHA Completed');
		$(form).trigger('submit');
	} else {
		console.log('reCAPTCHA Not Completed');
		formMessage(form, 'Please complete the reCAPTCHA in order to submit the form.', -1);
	}
	grecaptcha.reset(widget);
}

function formMessage(form, msg, state = 0) {
	form = $(form);
	id = form.data('id');
	info = $(form.data('info'));

	console.log('Form ' + id + ': ' + msg);
	info.text(msg);

	switch (state) {
		case 1:
			info.addClass('form-info-success');
			info.removeClass('form-info-error');
			break;
		case -1:
			info.addClass('form-info-error');
			info.removeClass('form-info-success');
			break;
		default:
			info.removeClass('form-info-success');
			info.removeClass('form-info-error');
	}
}

$('.form-ajax').submit(function(e) {
	e.preventDefault();

	var form = $(this);

	formMessage(form, 'Sending...', 0);

	$.ajax({
		type: form.attr('method'),
		url: form.attr('action'),
		dataType: 'json',
		data: form.serialize(),
		success: function(data) {
			console.log(data);
			formMessage(form, 'Thanks, your message has been sent. We\'ll respond ASAP.', 1);
			form.trigger('reset');
		},
		error: function(data) {
			console.log(data);
			formMessage(form, 'Sorry, something went wrong. Please email us manually instead.', -1);
		}
	});
});
