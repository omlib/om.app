package om.app;

class Window {

    /*
    public static function requestFullscreen() {
        //untyped document.body.webkitRequestFullscreen();
    }
    */

    public function new() {
    }

    public inline function isFullscreen() : Bool {

		#if chrome
		return win.isFullscreen();

		#elseif electron
		return document.fullscreenElement != null;
		//TODO return BrowserWindow.isFullScreen();

		#elseif web
		return untyped document.webkitFullscreenElement != null;

		#else
		      #if dev trace( 'not implemented' ); #end
		return null;

		#end
	}

	public function requestFullscreen() {

		if( isFullscreen() )
			return;

		#if chrome
		chrome.app.Window.current().fullscreen();

		#elseif electron
		untyped document.body.webkitRequestFullscreen();

		#elseif web
		untyped document.body.webkitRequestFullscreen();

		#end
	}

	public function exitFullscreen() {

		if( !isFullscreen() )
			return;

		#if chrome
		untyped document.webkitExitFullscreen();

		#elseif electron
		untyped document.webkitExitFullscreen();

		#elseif web
		untyped document.webkitExitFullscreen();

		#end
	}
}


/*
package samba;

import js.Browser.document;
import js.Browser.window;
import om.Console;

class Window {

	//public var onClose(default,null) : Signal<Window>;
	//public var onResize(default,null) = new Signal<Window>();
	//public var onFullscreenChange(default,null) : Signal<Window>;
	//public var onMaximized(default,null) : Signal<Window>;
	//public var onMinimized(default,null) : Signal<Window>;
	//public var onRestore(default,null) : Signal<Window>;

	public var top(get,null) : Int;
	public var left(get,null) : Int;

	public var width(get,null) : Int;
	public var height(get,null) : Int;

	public var minWidth(default,null) : Int;
	public var minHeight(default,null) : Int;

	public var maxWidth(default,null) : Int;
	public var maxHeight(default,null) : Int;

	public var resizeable(default,null) : Bool;
	public var transparent(default,null) : Bool;
	public var hidden(default,null) : Bool;
	public var alwaysOnTop(default,null) : Bool;
	public var focused(default,null) : Bool;

	/*
	#if chrome
	public var frame(default,null) : FrameOptions;
	#end

	#if web
	public var themeColor(get,null) : String;
	#end
	* /

	/** Last requested state (maybe not real state) * /
	public var fullscreen(default,null) : Bool;

	#if chrome
	var win : chrome.app.Window.AppWindow;
	#end

	function new() {

		//TODO set values from build config using build macro
		minWidth = minHeight = 50;
		maxWidth = maxHeight = 8192;

		resizeable = true;
		fullscreen = false;

		#if chrome
		win = chrome.app.Window.current();
		#end

		//window.addEventListener( 'resize', handleResize, false );
	}

	inline function get_width() : Int return window.innerWidth;
	inline function get_height() : Int return window.innerHeight;

	inline function get_top() : Int {

		#if chrome
		return win.outerBounds.top;

		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		return null;

		#end
	}

	inline function get_left() : Int {

		#if chrome
		return win.outerBounds.left;

		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		return null;

		#end
	}

	public inline function isFullscreen() : Bool {

		#if chrome
		return win.isFullscreen();

		#elseif electron
		return document.fullscreenElement != null;
		//TODO return BrowserWindow.isFullScreen();

		#elseif web
		return untyped document.webkitFullscreenElement != null;

		#else
		#if dev Console.warn( 'not implemented' ); #end
		return null;

		#end
	}

	public function requestFullscreen() {

		if( fullscreen )
			return;
		fullscreen = true;

		#if chrome
		chrome.app.Window.current().fullscreen();

		#elseif electron
		untyped document.body.webkitRequestFullscreen();

		#elseif web
		untyped document.body.webkitRequestFullscreen();

		#end
	}

	public function exitFullscreen() {

		if( !fullscreen )
			return;
		fullscreen = false;

		#if chrome
		untyped document.webkitExitFullscreen();

		#elseif electron
		untyped document.webkitExitFullscreen();

		#elseif web
		untyped document.webkitExitFullscreen();

		#end
	}

	public function toggleFullscreen() : Bool {
		fullscreen ? exitFullscreen() : requestFullscreen();
		return fullscreen;
	}

	public function minimize() {
		#if chrome
		win.minimize();
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		#end
	}

	public function maximize() {
		#if chrome
		win.maximize();
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		#end
	}

	public function isMinimized() : Bool {
		#if chrome
		return win.isMinimized();
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		return null;
		#end
	}

	public function isMaximized() : Bool {
		#if chrome
		return win.isMaximized();
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		return null;
		#end
	}

	public function focus() {
		#if chrome
		win.focus();
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		#end
	}

	public function close() {

		#if chrome
		win.close();

		#else
		#if dev Console.warn( 'window method not implemented' ); #end

		#end
	}

	public function isAlwaysOnTop() : Bool {
		#if chrome
		return win.isAlwaysOnTop();
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		return null;
		#end
	}

	public function setAlwaysOnTop( alwaysOnTop : Bool ) {
		#if chrome
		win.setAlwaysOnTop( alwaysOnTop );
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		#end
	}

	public function drawAttention() {
		#if chrome
		win.drawAttention();
		#else
		#if dev Console.warn( 'window method not implemented' ); #end
		#end
	}

	/*
	function handleResize(e) {
		//trace(e);
		//onResize.dispatch( this );
	}
	* /

	public static function current() : Window {
		return new Window();
	}

}

*/
