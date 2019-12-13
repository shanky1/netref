//Appica v1.1
//Copyright 2013 8Guild.com
//All scripts for iOS7 Style Template

/*Checking if it's touch device we disable some features due to inconsistency*/
if (Modernizr.touch) { 

		/*Preloading Animation*/
		$(window).load(function() {
			$('#status').fadeOut();
			$('#preloader').delay(300).fadeOut('slow'); 
			$('body').delay(300).css({'overflow':'visible'});
		});
		
		$('.animation').css('opacity', '1');
		
		$('body').removeClass('parallax'); 
		
} else {
	
		/*Preloading Animation*/
		$(window).load(function() {
			$('#status').fadeOut();
			$('#preloader').delay(300).fadeOut('slow'); 
			$('body').delay(300).css({'overflow':'visible'});
			setTimeout(function(){$('#phone').addClass('fadeInLeft');},300);
			setTimeout(function(){$('.info-block').addClass('fadeInRight');},300);
			setTimeout(function(){$('.social > .container').addClass('fadeInUp');},300);
			setTimeout(function(){$('.menu-toggle').addClass('bounceInDown');},300);
		});
	
//////////////////////////////////*SCROLL ANIMATIONS*/////////////////////////////////


			$('.animation').waypoint(function() {
					 var animation = jQuery(this).attr("data-animation");
					 $(this).addClass(animation);
					 $(this).addClass('animated');
			}, { offset: '75%' });
	
}


/*Document Ready*/
$(document).ready(function(e) {
	
//////////////////////////////////*BACKGROUND PARALLAX EFFECT*/////////////////////////////

	/*Background Parallax Effect*/
	$('.parallax').stellar();
	
/////////////////////////////////////////SCROLL-SPY*/////////////////////////////////////
	// Cache selectors
	var lastId,
		topMenu = $(".side-menu"),
		topMenuHeight = topMenu.outerHeight(),
		// All list items
		menuItems = topMenu.find("a"),
		// Anchors corresponding to menu items
		scrollItems = menuItems.map(function(){
		  var item = $($(this).attr("href"));
		  if (item.length) { return item; }
		});
	
	// Bind to scroll
	$(window).scroll(function(){
	   // Get container scroll position
	   var fromTop = $(this).scrollTop()+130;
	   
	   // Get id of current scroll item
	   var cur = scrollItems.map(function(){
		 if ($(this).offset().top < fromTop)
		   return this;
	   });
	   // Get the id of the current element
	   cur = cur[cur.length-1];
	   var id = cur && cur.length ? cur[0].id : "";
	   if (lastId !== id) {
		   lastId = id;
		   // Set/remove active class
		   menuItems
			 .parent().removeClass("active")
			 .end().filter("[href=#"+id+"]").parent().addClass("active");
	   }
	});

///////////////////////////////////////////////////////////////////////////////////////
	
/////////////////////////////////////////////////////////////////////////////////////////////

	/*Navigation Links Prevent Default Behaviour*/	
	$('nav ul li a').click(function(e){
		e.preventDefault();
	});
	
	/*Phone Slideshow*/
	$('#phone .slideshow ul').bxSlider({
		auto: true,
		mode: 'fade',
		speed: 900,
		pause: 5000,
		autoControls: false,
		pager: false,
		nextSelector: '.next',
		prevSelector: '.prev',
		nextText: '<i class="icon-next-arrow-ios"></i>',
		prevText: '<i class="icon-prev-arrow-ios"></i>'
	});
	
	
	/*Gallery Slider*/
	$('.gallery ul').bxSlider({
		auto: true,
		mode: 'horizontal',
		speed: 800,
		pause: 5000,
		autoControls: false,
		pager: true
	});
	
	
////////////////////////////////*Subscription Form Validation*//////////////////////////////
		 
	 function validateEmail(email)
		{
		 var reg = /^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/
		 if (reg.test(email)){
		 return true; }
		 else{
		 return false;
		 }
		} 
	 
	 $('#submit').click(function(){ 
		 var email = $('#email').val();
		 var error1 = $('#error1');
		 var error2 = $('#error2');
		 if ($.trim(email).length == 0) {
			 $(this).css('color', '#e35c4a');
			 error2.removeClass('visible');
			 error1.addClass('visible');
			 return false;
		 }
		 if (validateEmail(email)) {
			 $(this).css('color', '#6666cc');
			 error1.removeClass('visible');
			 error2.removeClass('visible');
			 return; 
			}
		 else {
			 $(this).css('color', '#e35c4a');
			 error1.removeClass('visible');
			 error2.addClass('visible');
			 return false;
	 }});

///////////////////////////////////////////////////////////////////////////////////////////
	
/////////////////////////////////////*SIDE MENU*///////////////////////////////////////////

	var sideMenu = $('.side-menu');
	var menuToggle = $('.menu-toggle');
	
	//Hide Side Menu when scrolling
	$(window).on('scroll', function(){
		sideMenu.removeClass('open');
	});
	
	//Side Menu Toggle
	menuToggle.click(function(e){
		e.preventDefault();
		sideMenu.toggleClass('open');
	});
	
	//Side Menu close init
	$('nav li a').click(function(){
		sideMenu.removeClass('open');
	});
	
/////////////////////////////////////////////////////////////////////////////////////////

	  
});/*/Document ready*/