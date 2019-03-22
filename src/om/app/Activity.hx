package om.app;

import js.html.Element;
import js.html.PopStateEvent;
import om.Browser.document;
import om.Browser.console;
import om.Browser.history;
import om.Browser.window;
import om.Promise;

private enum abstract State(String) to String {
	var create;
	var start;
	var resume;
	var pause;
	var stop;
	var destroy;
}

#if !macro
@:autoBuild(om.app.Build.activity())
#end
class Activity {

	public final id : String;
	public final element : Element;

	public var state(default,null) : State;
	public var parent(default,null) : Activity;

	public function new( ?id : String, ?element : Element ) {
		var cl = Type.getClass( this );
		this.id = (id == null) ? getActivityClassId( cl ) : id;
		this.element = (element == null) ? document.createDivElement() : element;
		this.element.classList.add( 'activity' );
		//TODO: createid, sid in build macro
		//this.element.id = (id == null) ? getActivityClassId( cl ) : id;
		//this.element.setAttribute( 'data-activity', this.id );
		this.element.classList.add( 'activity-'+this.id );
		var sid = getActivityClassId( cast Type.getSuperClass( cl ) );
		if( sid.length > 0 ) this.element.classList.add( sid );
	}

	//TODO all return Promise (?)

	function onCreate() {
	}

	function onStart<T>() : Promise<Null<T>>
		return Promise.resolve( null );
		//return Promise.nil();

	function onResume() {
	}

	function onPause() {
	}

	function onStop<T>() : Promise<Null<T>>
		return Promise.resolve( null );

	function onDestroy() {
	}
	
	function replace<T>( activity : Activity ) : Promise<T> {
		#if om_activity_console
		console.log( 'replace '+id+':'+activity.id );
		#end
		setState( pause );
		activity.parent = parent;
		activity.setState( create );
		element.parentNode.appendChild( activity.element );
		activity.setState( start );
		setState( stop );
		onStop().then( function(r){
			element.remove();
			setState( destroy );
		});
		return activity.onStart().then( function(r){
			activity.setState( resume );
			#if om_activity_history
			history.replaceState( {}, '' );
			#end
			return r;
		});
	}

	function push<T>( activity : Activity ) : Promise<T> {
		#if om_activity_console
		console.log( 'replace '+id+':'+activity.id );
		#end
		setState( pause );
		activity.parent = this;
		activity.setState( create );
		element.parentNode.appendChild( activity.element );
		activity.setState( start );
		/*
		setState( stop );
		onStop().then( function(r){
			element.remove();
			setState( destroy );
		});
		*/
		//element.remove();
		return activity.onStart().then( function(r){
			element.remove();
			#if om_activity_history
			history.pushState( {id:id}, '' );
			#end
			activity.setState( resume );
			return r;
		});
	}

	function pop<T>() : Promise<T> {
		if( parent == null )
			return Promise.reject('no parent');
		var activity = parent;
		#if om_activity_console
		console.log( 'pop '+id+':'+activity.id );
		#end
		setState( pause );
		element.parentNode.appendChild( activity.element );
		/*
		#if om_activity_history
		history.replaceState( {id:activity.id}, '' );
		#end
		*/
		activity.setState( resume );
		setState( stop );
		return onStop().then( function(r){
			element.remove();
			setState( destroy );
			return r;
		});
		/*
		return activity.onStart().then( function(r){
			activity.setState( resume );
			return r;
		});
		*/
	}

	function setState( state : State ) {
		if( this.state != null ) element.classList.remove( this.state );
		element.classList.add( this.state = state );
		switch state {
		case create:
			#if om_activity_console
			console.group( id, state );
			#end
			onCreate();
		case start:
			#if om_activity_console
			console.info( id, state );
			#end
		case pause:
			#if om_activity_console
			console.info( id, state );
			#end
			onPause();
			/*
			#if om_activity_history
			window.removeEventListener( 'popstate', handlePopState );
			#end
			*/
		case resume:
			#if om_activity_console
			console.info( id, state );
			#end
			onResume();
			/*
			#if om_activity_history
			window.addEventListener( 'popstate', handlePopState, false );
			#end
			*/
		case stop:
			#if om_activity_console
			console.info( id, state );
			#end
		case destroy:
			#if om_activity_console
			console.info( id, state );
			#end
			parent = null;
			onDestroy();
			#if om_activity_console
			console.groupEnd();
			#end
		default:
			console.warn( '???' );
		}
	}
	
	/*
	#if om_activity_history

	function handlePopState( e : PopStateEvent ) {
		console.debug( id, window.history.state, e );
		if( parent == null ) {
			trace('no parent');
			console.debug( "NNN", history.state );
		} else {
			console.debug( ">>>>", parent.id, history.state );
			pop();
		}
		/*
		if( parent != null && parent.id == window.history.state.id ) {
			pop();
		}
		* /
	}
	#end
	*/

	public static function boot<T>( activity : Activity, ?container : Element ) : Promise<T> {
		//if( activity.state != null )throw
		if( container == null ) container = document.body;
		activity.setState( create );
		container.appendChild( activity.element );
		activity.setState( start );
		return activity.onStart().then( function(r:T){
			activity.setState( resume );
			return r;
		});
	}

	static function getActivityClassId( cl : Class<Activity> ) : String {
		var cn = Type.getClassName( cl );
		cn = cn.substr( cn.lastIndexOf( '.' ) + 1 );
		return cn.substr( 0, cn.length - 'Activity'.length ).toLowerCase();
	}

}
