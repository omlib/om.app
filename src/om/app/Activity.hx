package om.app;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.Promise;
import js.html.Element;
import js.html.PopStateEvent;

enum abstract State(String) to String {
	var create;
	var start;
	var resume;
	var pause;
	var stop;
	var destroy;
}

/*
#if !macro
@:autoBuild(letter.app.Activity.build())
#end
*/
class Activity {

	public final id : String;

	public var state(default,null) : State;

	final element : Element;

	var parent : Activity;

	public function new( ?id : String, ?element : Element ) {
		this.element = (element == null) ? document.createDivElement() : element;
		this.element.classList.add( 'activity' );
		var cl = Type.getClass( this );
		this.id = this.element.id = (id == null) ? getActivityClassId( cl ) : id;
		var sid = getActivityClassId( cast Type.getSuperClass( cl ) );
		if( sid.length > 0 ) this.element.classList.add( sid );
	}

	function onCreate<T:Activity>() : Promise<T>
		return Promise.resolve( cast this );

	function onStart<T>() : Promise<T>
		return Promise.resolve( null );

	function onResume() {
	}

	function onPause() {
	}

	function onStop<T>() : Promise<T>
		return Promise.resolve( null );

	function onDestroy() {
	}

	function replace<T>( next : Activity ) : Promise<T> {
		setState( pause );
		next.setState( create );
		return next.onCreate().then( function(a:Activity) {
			element.parentNode.appendChild( a.element );
			a.setState( start );
			setState( stop );
			return Promise.race([
				onStop().then( function(_){
					element.remove();
					setState( destroy );
				}),
				a.onStart().then( function(r){
					a.setState( resume );
					return r;
				})
			]);
		});
	}

	function push<T>( next : Activity ) : Promise<T> {
		setState( pause );
		next.setState( create );
		return next.onCreate().then( function(a:Activity) {
			a.parent = this;
			element.parentNode.appendChild( a.element );
			a.setState( start );
			setState( stop );
			return Promise.race([
				onStop().then( function(_){
					element.remove();
				}),
				a.onStart().then( function(r){
					a.setState( resume );
					return r;
				})
			]);
		});
	}

	function pop<T>() : Promise<T> {
		if( parent == null )
			return Promise.reject('no parent');
		setState( pause );
		element.parentNode.appendChild( parent.element );
		parent.setState( start );
		setState( stop );
		return cast Promise.race([
			onStop().then( function(_){
				element.remove();
				setState( destroy );
			}),
			parent.onStart().then( function(r){
				parent.setState( resume );
				return r;
			})
		]);
	}

	function setState( state : State ) {
		if( this.state != null ) element.classList.remove( this.state );
		element.classList.add( this.state = state );
		switch state {
		case pause: onPause();
		case resume: onResume();
		case destroy: onDestroy();
		default:
		}
	}

	/*
	function handleStatePop( e : PopStateEvent ) {
		console.debug( e, window.history.state );
		console.debug( id );
		pop();
	}
	*/

	//public static var currrent(default,null) : Activity;

	public static function boot<T>( activity : Activity, ?element : Element ) : Promise<T> {

		if( element == null ) element = document.body;

	/*
		window.addEventListener( "popstate", function(e){
			console.debug(e,Activity.currrent.parent);
			if( e.state == null && Activity.currrent.parent != null ) {
				Activity.currrent.pop();
			}
			//console.debug(Activity.currrent.pop());
			//return 
		}, false );
*/

		activity.setState( create );
		return activity.onCreate().then( function(a:Activity){
			element.appendChild( a.element );
			a.setState( start );
			return a.onStart().then( function(r){
				a.setState( resume );
				//currrent = a;
				return r;
			});
		});
	}

	static function getActivityClassId( cl : Class<Activity> ) : String {
		var cn = Type.getClassName( cl );
		cn = cn.substr( cn.lastIndexOf( '.' ) + 1 );
		return cn.substr( 0, cn.length - 'Activity'.length ).toLowerCase();
	}

}
