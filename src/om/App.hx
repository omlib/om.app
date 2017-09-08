package om;

#if !macro
@:autoBuild(om.App.complete())
interface App {}
#else

import Sys.println;
import sys.FileSystem.*;
import sys.io.File;
import haxe.format.JsonPrinter;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import om.Res;
import om.style.LessC;

using om.Path;

typedef Ctx = {
    var name : String;
    var version : String;
    var platform : Platform;
    //var description : String;
};

typedef Build = {
    var num : Int;
    var total : Int;
    var date : Date;
    var duration : Float;
    var dev : Bool;
    var release : Bool;
}

typedef Meta = {
    var ctx : Ctx;
    var build : Build;
}

class App {

    static var ctx : Ctx;

    static function build() {

        var ts_start = Time.stamp();

        ctx = {
            name: getDefine( 'name', Sys.getCwd().directory().withoutDirectory() ),
            version: getDefine( 'version', '0.0.0' ),
            platform: getDefine( 'platform' ),
        };
        if( ctx.platform == null ) ctx.platform =
            Context.defined( 'om_electron' ) ? electron :
            Context.defined( 'om_android' ) ? android :
            web;

        var dev = getDefine( 'dev', false );
        var release = getDefine( 'release', false );

        var meta : Meta = null;
        if( exists( '.om/build.json' ) ) {
            meta = Json.parse( File.getContent( '.om/build.json' ) );
            meta.ctx = ctx;
            meta.build.total++;
            if( meta.ctx.version < ctx.version ) {
                meta.build.num = 0;
            } else {
                meta.build.num++;
            }
        } else {
            meta = {
                ctx: ctx,
                build: { num: 0, total: 0, date: null, duration: 0.0, dev: dev, release: release }
            };
        }

        if( !exists( '.om' ) ) createDirectory( '.om' );

        Context.onAfterGenerate( function() {

            buildResources();

            var tsEnd = Time.stamp();

            meta.build.duration = tsEnd - ts_start;
            meta.build.date = Date.now();

            File.saveContent( '.om/build.json', JsonPrinter.print( meta, '\t' ) );

            println( '${ctx.name}-${ctx.platform}-${ctx.version}.'+meta.build.num );
        });
    }

    static inline function warn( info : String, ?pos : Position )
        Context.warning( info, (pos == null) ? Context.currentPos() : pos );

    static function getDefine<T>( key : String, ?def : T ) : T {
        var k = 'om_app_$key';
        return Context.defined( k ) ? cast Context.definedValue( k ) : def;
    }

    static function buildResources() {

        syncDirectory( 'res/font', 'bin/font' );
        syncDirectory( 'res/icon', 'bin/icon' );
        syncDirectory( 'res/image', 'bin/image' );
        syncDirectory( 'res/mesh', 'bin/mesh' );
        syncDirectory( 'res/script', 'bin/script' );
        syncDirectory( 'res/sound', 'bin/sound' );
        syncDirectory( 'res/'+ctx.platform, 'bin' );

        LessC.compileFile( 'res/style/app.less', 'bin/app.css' );

        syncFile( 'res/html/app.html', 'bin/index.html' );
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
        if( ctx == null ) ctx = App.ctx;
        return new Template( File.getContent( src ) ).execute( ctx );
    }

    static function writeFile( path : String, content : String ) {
        var f = File.write( path );
        f.writeString( content );
        f.close();
    }

    static function fileNeedsUpdate( src : String, dst : String ) : Bool
        return exists( dst ) ? fileModTime( src ) > fileModTime( dst ) : true;

    static inline function fileModTime( path : String ) : Float
        return stat( path ).mtime.getTime();

    static function complete() {
        var fields = Context.getBuildFields();
		var pos = Context.currentPos();
        //TODO
        return fields;
    }
}

#end

@:enum abstract Platform(String) from String to String {
    var android = 'android';
    //var atom = 'atom';
    var chrome = 'chrome';
    var electron = 'electron';
    var nme = 'nme';
    var web = 'web';
}
