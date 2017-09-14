package om;

import om.app.Platform;

#if macro
import haxe.Template;
import haxe.format.JsonPrinter;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import om.Res;
import om.style.LessC;
import sys.FileSystem.*;
import sys.FileSystem;
import sys.io.File;
import Sys.println;
using om.Path;
#end

typedef Ctx = {
    var name : String;
    var version : String;
    var platform : Platform;
    var build : {
        var num : Int;
        var total : Int;
        var time : Float;
        var duration : Float;
        var dev : Bool;
        var release : Bool;
    }
};

#if !macro
@:autoBuild(om.App.complete())
#end
class App {

    public static inline var DEFINE_PREFIX = 'om_';

    macro public static function getContext() : ExprOf<Ctx>
        return macro $v{ctx};

    #if macro

    public static var ctx(default,null) : Ctx;

    static function build( ?ctx_ : Ctx ) {

        ctx = ctx_;
        Template.globals = ctx;

        var ts_start = Time.stamp();
        var path = Sys.getCwd().directory();
        var dir = path.withoutDirectory();

        if( ctx == null ) {
            ctx = {
                name:  getDefine( 'name', dir ),
                version: getDefine( 'version', '0.0.0' ),
                platform: getDefine( 'platform' ),
                build: {
                    num: 0,
                    total: 0,
                    duration: 0,
                    time: Date.now().getTime(),
                    dev: isDefined( 'dev', getDefine( 'dev', false, false ) ),
                    release: isDefined( 'om_release', isDefined( 'release', false, false ) ),
                }
            };
        }
        if( ctx.platform == null ) {
            ctx.platform =
                Context.defined( 'om_electron' ) ? electron :
                Context.defined( 'om_android' ) ? android :
                web;
        }

        Compiler.define( 'name' );
        Compiler.define( 'version', ctx.version );
        Compiler.define( 'platform', ctx.platform );
        switch ctx.platform {
        case android: Compiler.define( 'android' );
        case chrome: Compiler.define( 'chrome' );
        case electron: Compiler.define( 'electron' );
        case nme: Compiler.define( 'nme' );
        case web: Compiler.define( 'web' );
        }
        if( ctx.build.dev ) Compiler.define( 'dev' );
        if( ctx.build.release ) Compiler.define( 'release' );

        if( !exists( '.om' ) ) createDirectory( '.om' )
        else if( exists( '.om/context.json' ) ) {
            var meta = Json.parse( File.getContent( '.om/context.json' ) );
            ctx.build.num = meta.build.num;
            ctx.build.total = meta.build.num;
            if( meta.version < ctx.version ) ctx.build.num = 0;
        }
        ctx.build.num++;
        ctx.build.total++;
        ctx.build.duration = Time.stamp() - ts_start;

        Context.onAfterGenerate( function() {

            ctx.build.duration = Time.stamp() - ts_start;
            buildResources();
            ctx.build.duration = Time.stamp() - ts_start;

            File.saveContent( '.om/context.json', JsonPrinter.print( ctx, '\t' ) );

            println( '${ctx.name}-${ctx.platform}-${ctx.version}-'+ctx.build.num );
        });
    }

    static function complete() {
        var fields = Context.getBuildFields();
        var pos = Context.currentPos();
        //if( !fields.hasField( 'main' ) ) {
        /*
        if( !meta.build.release ) {
            fields.push({
                access: [APublic,AStatic],
                name: '__app__',
                kind: FVar( macro:Dynamic, macro $v{meta} ),
                pos: pos
            });
            var info = '${ctx.name}-${ctx.platform}-${ctx.version}.'+meta.build.num;
            fields.push({
                access: [APublic,AStatic,AInline],
                name: '__init__',
                kind: FFun( { args:[], expr: macro console.info( $v{info} ), ret: null } ),
                pos: pos
            });
        }
        */
        return fields;
    }

    static function isDefined( key : String, default_ = false, prefix = true ) : Bool {
        var k = prefix ? '$DEFINE_PREFIX$key' : key;
        return Context.defined( k ) ? true : default_;
    }

    static function getDefine<T>( key : String, ?default_ : T, prefix = true ) : T {
        var k = prefix ? '$DEFINE_PREFIX$key' : key;
        return Context.defined( k ) ? cast Context.definedValue( k ) : default_;
    }

    static function warn( info : String, ?pos : Position )
        Context.warning( info, (pos == null) ? Context.currentPos() : pos );

    static function buildResources() {

        syncDirectory( 'res/font', 'bin/font' );
        syncDirectory( 'res/icon', 'bin/icon' );
        syncDirectory( 'res/image', 'bin/image' );
        syncDirectory( 'res/mesh', 'bin/mesh' );
        syncDirectory( 'res/script', 'bin/script' );
        syncDirectory( 'res/sound', 'bin/sound' );
        //syncDirectory( 'res/'+ctx.platform, 'bin' );

        var lessFile = 'res/style/app.less';
        if( exists( lessFile ) ) LessC.compileFile( lessFile, 'bin/app.css' );

        var htmlFile = 'res/html/app.html';
        if( exists( htmlFile ) ) {
            //Context.registerModuleDependency();
            syncFile( htmlFile, 'bin/index.html' );
        }
    }

    static function isValidResName( fileName : String ) : Bool {
        var name = fileName.withoutDirectory();
        if( name.extension().length == 0 )
            return false;
        switch name.charAt(0) {
        case '.','_': return false;
        }
        //var regexp = ~/([a-z]+\.[a-z]+)/;
        return true;
    }

    static function syncDirectory( src : String, dst : String, recursive = true ) : Bool {
        if( !exists( src ) )
			return false;
        if( !exists( dst ) ) createDirectory( dst );
        for( f in readDirectory( src ) ) {
            var sp = '$src/$f';
			var dp = '$dst/$f';
			if( isDirectory( sp ) ) {
				//if( !exists( dst ) ) createDirectory( dst );
				if( recursive ) syncDirectory( sp, dp );
			} else {
				if( exists( dp ) ) {
					if( fileNeedsUpdate( sp, dp ) ) syncFile( sp, dp );
				} else {
					syncFile( sp, dp );
				}
			}
        }
        return true;
    }

    static function syncFile( src : String, dst : String ) {
        if( !exists( src ) || !isValidResName( src ) )
            return;
        if( Res.isTextFile( src ) ) {
            syncTextFile( src, dst );
        } else {
            syncBinaryFile( src, dst );
        }
    }

    static function syncTextFile( src : String, dst : String ) {
        if( isValidResName( src ) ) writeFile( dst, executeTemplate( src ) );
    }

    static function syncBinaryFile( src : String, dst : String ) {
        if( isValidResName( src ) && fileNeedsUpdate( src, dst ) ) File.copy( src, dst );
    }

    static function executeTemplate( src : String, ?ctx : Dynamic ) : String {
        if( ctx == null ) ctx = om.util.ReflectUtil.createCopy( App.ctx );
        Reflect.setField( ctx, ctx.platform, true );
        var tpl = new Template( File.getContent( src ) );
        return try tpl.execute( ctx ) catch(e:Dynamic) {
            trace( e );
            null;
        }
    }

    static function writeFile( path : String, content = '' ) {
        var f = File.write( path );
        f.writeString( content );
        f.close();
    }

    static function fileNeedsUpdate( src : String, dst : String ) : Bool
        return exists( dst ) ? fileModTime( src ) > fileModTime( dst ) : true;

    static inline function fileModTime( path : String ) : Float
        return stat( path ).mtime.getTime();

    #end

}
