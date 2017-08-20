package om.macro;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using om.macro.FieldTools;

class BuildApp {

	static function complete() : Array<Field> {

		var fields = Context.getBuildFields();
		var pos = Context.currentPos();
		var app = om.app.Build.app;
		var meta = om.app.Build.meta;

		if( !fields.hasField( 'main' ) ) {
			//if( fields.hasField( 'init' ) ) {
			fields.push({
				access: [AStatic],
				name: 'main',
				kind: FFun({
					expr: Context.parseInlineString( 'js.Browser.window.onload=function(_){init();}', pos ),
					ret: null,
					args: [],
				}),
				pos: pos
			});
		}

		if( !fields.hasField( 'NAME' ) ) addConstField( fields, 'NAME', app.name );
		if( !fields.hasField( 'PLATFORM' ) ) addConstField( fields, 'PLATFORM', app.platform );
		if( !fields.hasField( 'VERSION' ) ) addConstField( fields, 'VERSION', app.version );

		//trace( meta );
		// Forces haxe compilation
		//if( !fields.hasField( 'BUILD_NUM' ) ) addConstField( fields, 'BUILD', meta.total, macro:Int );
		//if( !fields.hasField( 'BUILD_TIME' ) ) addConstField( fields, 'BUILD_TIME', Date.now().toString() );

		/*
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var localType = Context.getLocalType();
		var localClassType : ClassType = null;
		var localClassName : String = null;
		var localMeta : AppMeta = null;

		switch localType {
		case TInst(c,_):
			localClassType = c.get();
			localClassName = localClassType.name;
			var appMeta = localClassType.meta.extract( 'app' );
			if( appMeta.length > 0 ) {
				localMeta = ExprTools.getValue( appMeta[0].params[0] );
			}
      	case _:
		}

		//trace( localMeta );

		if( localMeta != null ) {
			if( localMeta.script != null ) {
				for( f in localMeta.script ) {
					var path = 'res/script/$f';
					if( !sys.FileSystem.exists( path ) )
						abort( 'file not found: $path' );
					Compiler.includeFile( path );
				}
			}
		}

		/*
		if( !fields.hasField( 'init' ) ) {
			Context.warning( 'Missing init() method', pos );
		} else {
			//TODO
		}
		* /

/*
'
	window.onload = function() {
		window.addEventListener( "beforeunload", function(e) {
			js.Browser.getLocalStorage().setItem( NAME, om.Json.stringify( serialize() ) );
			return null;
		});
		init( om.Json.parse( window.localStorage.getItem(NAME) ) );
	}'
* /
		if( !fields.hasField( 'main' ) ) {
			fields.push({
	    		access: [AStatic],
				name: 'main',
	    		kind: FFun({
					expr: Context.parseInlineString( '
						window.onload = function() {
							init();
						}', pos ),
					ret: null,
					args: [],
				}),
	    		pos: pos
	    	});
		}

		/*
		if( sys.FileSystem.exists( '$res/script' ) ) {
			for( file in sys.FileSystem.readDirectory( '$res/script' ) ) {
				if( file.extension() == 'js' )
					Compiler.includeFile( '$res/script/$file', Top );
			}
		}
		*/

        return fields;
    }

	static function addConstField<T>( fields : Array<Field>, name : String, value : T, ?type : ComplexType ) {

		if( type == null ) type = macro:String;

		fields.push({
			access: [APublic,AStatic,AInline],
			name: name,
			kind: FVar( type, macro $v{value} ),
			pos: Context.currentPos()
		});
	}
}

#end
