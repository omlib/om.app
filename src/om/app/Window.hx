package om.app;

#if js

import js.Browser.document;

class Window {

	public static inline function isFullscreen() : Bool {

		#if chrome_app
		return win.isFullscreen();

		#else
		return untyped document.webkitFullscreenElement != null;

		#end
	}

	public static inline function requestFullscreen() {

		#if chrome_app
		chrome.app.Window.current().fullscreen();

		#elseif web
		//untyped document.body.webkitRequestFullscreen();
		untyped document.documentElement.webkitRequestFullscreen();

		#end
	}

	public static inline function exitFullscreen() {

		#if chrome_app
		untyped document.webkitExitFullscreen();

		//#elseif electron
		//untyped document.webkitExitFullscreen();

		#elseif web
		untyped document.webkitExitFullscreen();

		#end
	}

	public static inline function toggleFullscreen() {
		isFullscreen() ? exitFullscreen() : requestFullscreen();
	}
}

#end
