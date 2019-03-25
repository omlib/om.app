package om;

#if macro
import haxe.Template;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import Sys.println;
import om.app.Platform;
using haxe.macro.ExprTools;
using om.Path;
#end

#if macro

class App {

	public static var NAME(default,null) : String;
	public static var VERSION(default,null) = "0.0.0";
	public static var RELEASE(default,null) = 0;
	public static var REVISION(default,null) = 0;
	public static var PLATFORM(default,null) : Platform;
	//public static var BUILDTIME(default,null) = Date.now().toString();

	static function __build__() {

		var cwd = Sys.getCwd();

		NAME = getFlag( 'NAME', cwd.directory().withoutDirectory() );
		VERSION = getFlag( 'VERSION', VERSION );
		RELEASE = getIntFlag( 'RELEASE', RELEASE );
		REVISION = getIntFlag( 'REVISION', REVISION );
		PLATFORM = getFlag( 'PLATFORM' );
		if( PLATFORM == null ) {
			PLATFORM = if( isDefined( 'android' ) ) Android;
			else if( isDefined( 'electron' ) ) Electron;
			else if( isDefined( 'chrome_app' ) ) Chrome;
			else Web;
		}

		Context.onAfterGenerate( function(){
			//Sys.println( '23' );
		});
	}

	static function __complete__() : Array<Field> {

		var fields = Context.getBuildFields();
		var pos = Context.currentPos();
		var cl = Context.getLocalClass().get();

		var ctx = { platform : PLATFORM };

		/*
		//trace("TODO create platform specific index.html");
		if( cl.meta.has(':html') ) {
			//trace( cl.meta.extract(':html')[0].params[0].getValue() );
			//var path = cl.meta.extract(':html')[0].params[0].getValue();
			//trace(path);
			//trace(ctx);
			var src = 'res/html/index.html';
			var dst = 'app/index.html';
			if( FileSystem.exists( src ) ) {
				var html = new Template( File.getContent( src ) ).execute( ctx );
				//trace(html);
				File.saveContent( dst, html );
			}
		}
		*/

		fields.push({
			name : "NAME",
			access : [APublic,AStatic,AInline],
			kind: FVar( macro : String, macro $v{NAME} ),
			meta : [{ name : ':keep', pos : pos }],
			pos : pos
		});
		fields.push({
			name : "VERSION",
			access : [APublic,AStatic,AInline],
			kind: FVar( macro : String, macro $v{VERSION} ),
			meta : [{ name : ':keep', pos : pos }],
			pos : pos
		});
		fields.push({
			name : "RELEASE",
			access : [APublic,AStatic,AInline],
			kind: FVar( macro : Int, macro $v{RELEASE} ),
			meta : [{ name : ':keep', pos : pos }],
			pos : pos
		});
		fields.push({
			name : "REVISION",
			access : [APublic,AStatic,AInline],
			kind: FVar( macro : Int, macro $v{REVISION} ),
			meta : [{ name : ':keep', pos : pos }],
			pos : pos
		});
		fields.push({
			name : "PLATFORM",
			access : [APublic,AStatic,AInline],
			kind: FVar( macro : om.app.Platform, macro $v{PLATFORM} ),
			meta : [{ name : ':keep', pos : pos }],
			pos : pos
		});
		/*
		fields.push({
			name : "BUILDTIME",
			access : [APublic,AStatic,AInline],
			kind: FVar( macro : String, macro $v{Date.now().toString()} ),
			meta : [{ name : ':keep', pos : pos }],
			pos : pos
		});
		*/

        return fields;
	}

	static inline function isDefined( key : String ) : Bool
        return Context.defined( key );

	static function getFlag( key : String, ?def : String ) : String
        return isDefined( key ) ? Context.definedValue( key ) : def;

	static function getIntFlag( key : String, ?def : Int ) : Int
        return isDefined( key ) ? Std.parseInt( Context.definedValue( key ) ) : def;

	static function getFloatFlag( key : String, ?def : Float ) : Float
        return isDefined( key ) ? Std.parseFloat( Context.definedValue( key ) ) : def;

}

#else

#if android
import om.android.App;
#end

@:autoBuild(om.App.__complete__())
interface App {}

#end
