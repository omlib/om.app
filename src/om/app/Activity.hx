package om.app;

import js.Browser.document;
import js.html.Element;

/*
class ErrorActivity extends Activity {

	function new( error : Error, ?id : String, ?element : Element ) {
		super( id, element );
		if( error != null ) this.element.textContent = error.message;
	}
}
*/

/*
//TODO complete methods (?)
#if !macro
@:autoBuild(letter.app.Activity.build())
#end
*/
class Activity {

	public final id : String;
	//public final element : Element;
	//public var state(default,null) : State;

	var element : Element;
	var parent : Activity;

	public function new( ?id : String, ?element : Element ) {
		if( id == null ) {
            var cn = Type.getClassName( Type.getClass( this ) );
			cn = cn.substr( cn.lastIndexOf( '.' ) + 1 );
			cn = cn.substr( 0, cn.length - 'Activity'.length );
			id = cn.toLowerCase();
		} // else TODO check class name
		this.id = id;
		this.element = (element == null) ? document.createDivElement() : element;
		this.element.id = this.id;
		this.element.classList.add( 'activity' );
	}

	//TODO no promise ?
	function onCreate<T:Activity>() : Promise<T> {
		return Promise.resolve( cast this );
	}

	function onStart<T>() : Promise<T> {
		return Promise.resolve( cast this );
	}

	function onResume() {}

	function onPause() {}

	function onStop<T>() : Promise<T> {
		return Promise.resolve( null );
	}

	function onDestroy() {}

	function replace<T>( next : Activity ) : Promise<T> {
		onPause();
		return next.onCreate().then( function(activity:Activity) {
			//activity.parent = this;
			trace();
			element.parentNode.appendChild( activity.element );
			return activity.onStart().then( function(r){
				onStop();
				element.remove();
				activity.onResume();
				onDestroy();
				return r;
			});
		});
	}

	function push<T>( next : Activity ) {
		onPause();
		return next.onCreate().then( function(activity:Activity) {
			activity.parent = this;
			element.parentNode.appendChild( activity.element );
			return activity.onStart().then( function(r){
				onStop();
				element.remove();
				activity.onResume();
				//onDestroy();
				return r;
			});
		});
	}

	function pop() {
		if( parent == null )
			return Promise.reject('no parent');
		onPause();
		element.parentNode.appendChild( parent.element );
		return parent.onStart().then( function(r){
			onStop();
			element.remove();
			parent.onResume();
			onDestroy();
		});
	}

	/*
	function finish() {
		//if( parent == null ) return Promise.reject('no parent');
		onPause();
		onStop();
		element.remove();
		onDestroy();
	}
	*/

	public static function boot<T>( activity : Activity, ?element : Element ) : Promise<T> {
		if( element == null ) element = document.body;
		return activity.onCreate().then( function(a:Activity){
			element.appendChild( a.element );
			return a.onStart().then( function(r){
				activity.onResume();
				return r;
			});
		});
	}


	////////////////////////

	/*
	public static var container(default,null) : Element;
	public static var errorActivityClass : Class<Activity>;

	static var stack : Array<Activity>;

	public static function boot<T:Activity>( activity : Activity, ?container : Element, ?errorActivityClass : Class<Activity> ) : Promise<T> {

		//if( stack !=  null ) //TODO reset?

		Activity.container = (container == null) ? document.body : container;
		Activity.errorActivityClass = (errorActivityClass == null) ? ErrorActivity : errorActivityClass;
		Activity.stack = [];

		console.group( 'init: '+activity.id );

		Activity.container.appendChild( activity.element );

		return activity.onCreate().then( function(_){

			stack.push( activity );
			activity.onStart();

			console.groupEnd();

			return cast activity;

		}).catchError( function(e){

			var error : Error = Std.is( e, Error ) ? cast e : new Error(e);
			trace(error);

			activity.element.remove();
			stack = [];
			var errorActivity = Type.createInstance( Activity.errorActivityClass, [error] );
			Activity.container.appendChild( errorActivity.element );
			return cast errorActivity.onCreate().then( function(_){
				//trace("EE");
				errorActivity.onStart();
				//return cast errorActivity;
			}).catchError( function(e){
				console.error( e );
			});
		});
	}

	//TODO make these non-static, for full stack chaining (and running in non global context ?)

	//TODO optional onStartParams?
	//public static function set<T:Activity>( activity : T, ?params ) : Promise<T> {
	public static function set<T:Activity>( activity : T ) : Promise<T> {

		console.group( 'set: '+activity.id );

		container.appendChild( activity.element );

		return activity.onCreate().then( function(_) {

			if( stack.length > 0 ) {
				var cur = stack.pop();
				cur.onStop();
				cur.element.remove();
				cur.onDestroy();
			}
			stack.push( activity );

			activity.onStart();

			console.groupEnd();
			//TODO return activity.onStart();
			return cast activity;
		});
	}

	public static function push<T:Activity>( activity : T ) : Promise<T> {

		console.group( 'push: '+activity.id );

		container.appendChild( activity.element );

		return activity.onCreate().then( function(_){
			if( stack.length > 0 ) {
				var cur = stack[stack.length-1];
				cur.onStop();
				cur.element.remove();
			}
			stack.push( activity );
			activity.onStart();

			console.groupEnd();

			return cast activity;
		});
	}

	public static function pop() {

		if( stack.length < 2 )
			return;

		var cur = stack.pop();
		var pre = stack[stack.length-1];

		console.group( 'pop: '+cur.id );

		cur.onStop();

		container.appendChild( pre.element );
		pre.onStart();

		cur.element.remove();
		cur.onDestroy();

		console.groupEnd();
	}
	*/

}
