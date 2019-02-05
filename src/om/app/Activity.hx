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
		console.log( 'replace '+id+':'+activity.id );
		setState( pause );
		activity.setState( create );
		activity.parent = parent;
		element.parentNode.appendChild( activity.element );
		activity.setState( start );
		setState( stop );
		onStop().then( function(r){
			element.remove();
			setState( destroy );
		});
		return activity.onStart().then( function(r){
			history.replaceState( {}, '' );
			activity.setState( resume );
			return r;
		});
	}

	function push<T>( activity : Activity ) : Promise<T> {
		console.log( 'replace '+id+':'+activity.id );
		setState( pause );
		activity.setState( create );
		activity.parent = this;
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
			history.pushState( {id:id}, '' );
			activity.setState( resume );
			return r;
		});
	}

	function pop<T>() : Promise<T> {
		if( parent == null )
			return Promise.reject('no parent');
		var activity = parent;
		console.log( 'pop '+id+':'+activity.id );
		setState( pause );
		element.parentNode.appendChild( activity.element );
		history.replaceState( {id:activity.id}, '' );
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
			console.group( id, state );
			onCreate();
		case start:
			console.info( id, state );
		case resume:
			console.info( id, state );
			onResume();
			window.addEventListener( 'popstate', handlePopState, false );
		case pause:
			console.info( id, state );
			window.removeEventListener( 'popstate', handlePopState );
		case stop:
			console.info( id, state );
		case destroy:
			console.info( id, state );
			parent = null;
			onDestroy();
			console.groupEnd();
		default:
			console.warn( '???' );
		}
	}
	
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
		*/
	}

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
