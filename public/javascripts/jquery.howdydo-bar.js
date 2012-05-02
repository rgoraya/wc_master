// JavaScript Document
/*
 * This is a simple jQuery notification bar inspired by the stackoverflow.com notification bar and the Hello Bar.
 * 
 * Version 0.1.8
 * March 08, 2012
 *
 * Howdy-do Notification Bar w/ jQuery by Leo Silva is licensed under a 
 * Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 * 
 * USAGE AND OPTONS:
 *
 *	$('#myDiv').howdyDo({
 *		action		: 'hover', 			// bar behavior: hover | push | scroll | pushscroll
 *		effect		: 'slide', 			// howdy-do bar effect: blind | drop | fade | slide
 *		easing		: 'easeOutBounce', 	// jQuery UI easing
 *		duration	: 500,		 		// effect duration/speed in milliseconds
 *		delay		: 500, 				// delay before autoStart in milliseconds
 *		hideAfter	: 0, 				// autoHide delay in milliseconds
 *		initState	: 'closed', 		// initial bar state: 'closed' | 'open'
 *		keepState	: true, 			// sets cookie to remember previous bar state.
 *		autoStart	: true, 			// shows bar on page load
 *		softClose	: false				// closes the bar on a document click (outside the bar)
 *		barClass	: 'howdydo-style',	// your own customized Howdy-do bar style
 *		openAnchor	: 'show', 			// html element or text
 *		closeAnchor	: 'hide',			// html element or text
 *		callback	: function(){}		// callback function
 *	});
 *
 * TESTED WITH:
 *	FF 3.6, Opera 11, IE 9, Chrome 8, Safari 5.0.3
 *	jQuery v.1.4.4
 *	jQueryUI v.1.8.7
 */
( function($) {
	$.fn.howdyDo = function( options ){
		var defaults = {
			action		: 'hover', 			// bar behavior: hover | push | scroll | pushscroll
			effect		: 'slide', 			// howdy-do bar effect: blind | drop | fade | slide
			easing		: 'easeOutBounce', 	// jQuery UI easing
			duration	: 500,		 		// effect duration/speed in milliseconds
			delay		: 500, 				// delay before autoStart in milliseconds
			hideAfter	: 0, 				// autoHide delay in milliseconds: 0 (disabled)
			initState	: 'closed', 		// initial bar state: 'closed' | 'open'
			keepState	: true, 			// sets cookie to remember previous bar state
			autoStart	: true, 			// shows bar on page load
			softClose	: false,			// closes the bar on a document click (outside the bar)
			barClass	: 'howdydo-style',	// your own customized Howdy-do bar style
			openAnchor	: 'show', 			// html element or text
			closeAnchor	: 'hide',			// html element or text
			callback	: function(){}		// callback function
		};
		var options = $.extend( defaults, options );
		
		var obj = $(this);
		obj.detach().prependTo( 'body' ).wrap( '<div id="howdydo-wrapper">' ); // detach, move target element to after <body> tag and wrap it in a <div>

		var openBar = '<div id="howdydo-open" class="' + options.barClass + '"><a style="margin:0; padding:0;" href="javascript:;">' + options.openAnchor + '</a></div>'; // creates opening anchor
		var closeBar = '<div id="howdydo-close"><a href="javascript:;">' + options.closeAnchor + '</a></div><div style="clear:both;"></div>' // creates closing anchor

		obj.addClass( options.barClass + ' howdydo-box' ).html( obj.html() + closeBar ).after( openBar ); // add custom and requerd classes to target element and place open and close anchors

		var objWrapper = $( '#howdydo-wrapper' ); // target wrapper element
		var objOpen = $( '#howdydo-open' ); // open anchor element
		var objClose = $( '#howdydo-close' ); // close anchor element

		objWrapper.after("<div style='clear:both;'></div>"); // clear <div> hack

		switch( options.action ){ // set element classes according to optons.action
			case 'scroll'		: objWrapper.addClass( 'howdydo-scroll' ); break;
			case 'push'			: objWrapper.addClass( 'howdydo-push' ).after( '<div id="howdydo-stretch">' ); break;
			case 'pushscroll'	: objWrapper.addClass( 'howdydo-scroll' ).after( '<div id="howdydo-stretch">' ); break;
			default				: objWrapper.addClass( 'howdydo-hover' );
		}

		if( $( '#howdydo-stretch' ).length ){ var objStretch = $( '#howdydo-stretch' ); }

		switch( options.effect ){ // effect options, per effect type
			case 'blind': effectOptions = { direction: 'vertical', easing: options.easing }; break;
			case 'drop'	: effectOptions = { direction: 'up', easing: options.easing }; break;
			case 'fade'	: effectOptions = {}; break;
			default		: options.effect = 'slide'; effectOptions = { direction: 'up', easing: options.easing };
		}

		objClose.bind( 'click', function(){ if ( !objClose.is( ':animated' ) ) { howdydoHide(); } }); // hide/close on click
		objOpen.bind( 'click', function(){ if ( !objOpen.is( ':animated' ) ) { howdydoShow(); } }); // show/open on click

		$( document ).keyup( function( e ) { if( e.keyCode == 27 && obj.is( ':visible' ) ){ howdydoHide();} }); // close on Esc
		if( options.softClose == true ) { // close on click on document, outside bar
			obj.click( function( e ) { e.stopPropagation(); });
			$( document ).click( function(){ howdydoHide() });
		}

		if( options.keepState == true ){
			var cookieVal = getHowdydoCookie( 'HowdydoBarState' ); // get cookie value
			if( cookieVal == null || cookieVal == '' ){ // if cookie value is null
				var barState = options.initState;
				if( options.autoStart == true ) {
					if( barState == 'closed' ) { howdydoShow( options.delay ); } // show bar if autoStart == true and initState == 'closed'
					else { // change css and set cookie
						howdydoOpen( true );
						if( options.hideAfter > 0 && options.autoStart == true ) { barAnim = setTimeout( function(){ howdydoHide(); }, ( options.hideAfter + options.duration + options.delay ) ); options.hideAfter = 0; }
					}
				}
			} else { // if cookie value exists
				var barState = cookieVal;
				if( cookieVal == 'open' ){ howdydoOpen( true ); } // change css and set cookie
			}
			options.hideAfter = 0;
		} else { // not set to keepState the last state
			if( options.initState == 'closed' && options.autoStart == true ){ howdydoShow( options.delay ); } // show bar
			else if( options.initState == 'open' ){ 
				howdydoOpen( false ); // change css
				if( options.hideAfter > 0 && options.autoStart == true ) { barAnim = setTimeout( function(){ howdydoHide(); }, ( options.hideAfter + options.duration + options.delay ) ); options.hideAfter = 0; }
			}
		}

		function howdydoOpen( setCookie ){ // open bar by changing CSS and set cookie
			obj.css( 'display', 'block' );
			objOpen.css( 'display', 'none' );
			if( objStretch && objStretch.length ) { objStretch.height( obj.outerHeight() ); }
			if( setCookie == true ){ setHowdydoCookie( 'HowdydoBarState', 'open' ); }
		}

		function howdydoShow( delay ){ // show bar 
			if( !obj.is( ':animated, :visible' ) ) {
				if( !delay || delay < 0 ) { delay = 0; }
				setTimeout( function(){
					if( options.action == 'push' || options.action == 'pushscroll' ) {
						objOpen.hide( options.effect, effectOptions, options.duration, function() {
							objStretch.animate( { height: obj.outerHeight() }, 250,  function() {
								obj.show( options.effect, effectOptions, options.duration, options.callback );
							});
						});
					} else {
						objOpen.hide( options.effect, effectOptions, options.duration, function(){
							obj.show( options.effect, effectOptions, options.duration, options.callback );
						});
					}
				}, delay );
				setHowdydoCookie( 'HowdydoBarState', 'open' );
				if( options.hideAfter > 0 && options.autoStart == true ) { barAnim = setTimeout( function(){ howdydoHide(); }, ( options.hideAfter + options.duration + options.delay ) ); options.hideAfter = 0; }
			}
		}

		function howdydoHide(){ // hide bar
			if( !obj.is( ':animated, :hidden' ) ) {
				if( typeof barAnim != 'undefined' ) { clearTimeout( barAnim ); }
				if( options.action == 'push' || options.action == 'pushscroll' ) {
					obj.hide( options.effect, effectOptions, options.duration, function() {
						objStretch.animate( { height: 0 }, 250, function() {
							objOpen.show( options.effect, effectOptions, options.duration, options.callback );
						});
					});
				} else {
					obj.hide( options.effect, effectOptions, options.duration, function(){
						objOpen.show( options.effect, effectOptions, options.duration, options.callback );
					});
				}
				setHowdydoCookie( 'HowdydoBarState', 'closed' );
			}
		}
		
		function setHowdydoCookie( name, value ){ // set cookie
			if( options.keepState == true ) {
				var date = new Date();
				date.setDate( date.getDate() + 1 );
				expDate = date.toGMTString();
				document.cookie = name + "=" + value +";expires=" + expDate + "; path=/";
			}
		}

		function getHowdydoCookie( name ) { // read cookie value
			var nameEQ = name + "=";
			var ca = document.cookie.split(';');
			for( var i=0;i < ca.length;i++ ) {
				var c = ca[i];
				while ( c.charAt( 0 ) == ' ' ) c = c.substring( 1, c.length ); 
				if ( c.indexOf( nameEQ ) == 0 ) return c.substring( nameEQ.length, c.length );
			}
			return null;
		}
	}
})( jQuery );