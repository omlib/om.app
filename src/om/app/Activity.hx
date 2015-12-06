package om.app;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.Element;
import js.html.DivElement;
import js.html.PopStateEvent;

using StringTools;

enum ActivityState {
    init;
    create;
    start;
    restart;
    resume;
    pause;
    stop;
    destroy;
}

class Activity {

    public static inline var NAME_POSTFIX = 'Activity';

    static var stack = new Array<Activity>();

    ////////////////////////////////////////////////////////////////////////////

    public var id(default,null) : String;
    public var element(default,null) : DivElement;
    public var state(default,null) : ActivityState;
    public var container(default,null) : Element;

    public function new( ?id : String ) {

        if( id == null ) {
            var cName = Type.getClassName( Type.getClass( this ) );
            var i = cName.lastIndexOf( '.' );
            if( i != -1 ) cName = cName.substring( i+1 );
			if( cName.endsWith( NAME_POSTFIX ) )
                cName = cName.substring( 0, cName.length - NAME_POSTFIX.length );
            #if debug
                else trace( 'Activity class name should end with "Activity"' );
            #end
            id = cName.toLowerCase();
        }
        this.id = id;

        element = document.createDivElement();
        element.classList.add( 'activity' );
        element.id = id;

        state = init;
    }

    ////////////////////////////////////////////////////////////////////////////

    function push( activity : Activity, ?delay : Int ) {

        __log__( 'push: '+activity.id );

        if( activity.container == null ) activity.container = container;
        activity.onCreate();
        activity.onStart();
        onPause();

        if( delay != null && delay > 0 ) {

            haxe.Timer.delay(function(){

                activity.onResume();
                onStop();

                stack.push( activity );

                window.history.pushState( null, null, null );

            }, delay );

        } else {

            activity.onResume();
            onStop();

            stack.push( activity );

            window.history.pushState( null, null, null );
        }
    }

    function replace( activity : Activity ) {

        __log__( 'replace: '+id+' < '+activity.id );

        activity.container = container;
        activity.onCreate();
        activity.onStart();
        onPause();
        activity.onResume();
        onStop();
        onDestroy();

        stack.pop();
        stack.push( activity );

        //window.history.replaceState( { id : activity.id }, null, activity.id );
        window.history.replaceState( null, null, null );
    }

    function pop() {

        __log__( 'pop: '+id );

        if( stack.length < 2 ) {
            __log__( 'no prev activity' );

        } else {

            stack.pop();

            var prev = stack[stack.length-1];
            //prev.onStart();
            prev.onRestart();
            onPause();
            prev.onResume();
            onStop();
            onDestroy();

            //window.history.replaceState( { id : prev.id }, null, prev.id );
            window.history.replaceState( null, null, null );
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    function onCreate() {

        __log__( '===== $id onCreate' );

        handleStateChange( create );
    }

    function onRestart() {

        __log__( '===== $id onRestart'  );

        handleStateChange( restart );
        onStart();
    }

    function onStart() {

        __log__( '===== $id onStart' );

        handleStateChange( start );

        window.addEventListener( 'popstate', handlePopState, false );

        //app.dom.appendChild( dom );
        //document.body.appendChild( element ); //TODO
        container.appendChild( element );

        //dom.classList.remove( 'pause' );
        //dom.classList.add( 'start' );
    }

    function onResume() {

        __log__( '===== $id onResume' );

        handleStateChange( resume );
        //dom.classList.remove( 'pause' );
        //dom.classList.add( 'resume' );
    }

    function onPause() {

        __log__( '===== $id onPause' );

        handleStateChange( pause );
        //dom.classList.remove( 'resume' );
        //dom.classList.add( 'pause' );

        //dom.classList.remove( 'start' );
        //dom.classList.add( 'pause' );
    }

    function onStop() {

        __log__( '===== $id onStop' );

        handleStateChange( stop );

        window.removeEventListener( 'popstate', handlePopState );

        element.remove();
    }

    function onDestroy() {

        __log__( '===== $id onDestroy' );

        handleStateChange( destroy );
    }

    ////////////////////////////////////////////////////////////////////////////

    //function pushHistoryState()

    ////////////////////////////////////////////////////////////////////////////

    function handleStateChange( newState : ActivityState ) {
        element.classList.remove( Std.string( state ) );
        state = newState;
        element.classList.add( Std.string( newState ) );
    }

    function handlePopState( e : PopStateEvent ) {

        __log__( 'pop state' );

        e.preventDefault();
        e.stopPropagation();

        //pop();

        if( stack.length < 2 ) {
            trace( 'No prev activity' );
            //return false;

        } else {

            var current = stack.pop();
            //trace('CURRENT:'+current.id +' < PREV: '+ e.state.id );

            var prev = stack[stack.length-1];
            //prev.onStart();
            prev.onRestart();
            onPause();
            prev.onResume();
            onStop();
            onDestroy();

            //window.history.replaceState( {state:prev.id}, null, prev.id );
            window.history.replaceState( null, null, null );
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    inline function appendChild( child : Element ) {
        element.appendChild( child );
    }

    ////////////////////////////////////////////////////////////////////////////

    inline function __log__( msg : String ) {
        #if activity_debug console.debug( msg ); #end
    }

    ////////////////////////////////////////////////////////////////////////////

    function boot( ?container : Element ) {
        this.container = (container != null) ? container : document.body;
        onCreate();
        onStart();
    }
}