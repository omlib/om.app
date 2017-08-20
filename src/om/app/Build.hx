package om.app;

#if macro

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import om.io.FileSync.*;
import om.io.FileUtil;
import sys.FileSystem;
import sys.io.File;
import Sys.println;

using om.Path;

class Build {

    public static inline var DEFINE_PREFIX = '';
    public static inline var RES = 'res';
    public static inline var OUT = 'bin';

    public static var verbose = false;

    public static var app(default,null) : App;
    public static var meta(default,null) : Meta.Data;

    public static var res(default,null) = RES;
    public static var out(default,null) = OUT;

    public static function run() {

        var timeBuildStart = Time.stamp();

        //trace(Sys.args());
        //res = resPath;
        //out = outPath;

        app = new App(
            getDefine( 'app', Sys.getCwd().directory().withoutDirectory() ),
            getDefine( 'version', '0.0.0' ),
            getDefine( 'platform' )
        );

        if( app.platform == null ) {
            app.platform =
                if( Context.defined( 'android' ) ) android
                else if( Context.defined( 'electron' ) ) electron
                else web;
        }

        app.debug = getDefine( 'debug', false );
        app.release = getDefine( 'release', false );

        if( app.release ) {
            if( app.debug ) {
                warning( 'You are in release mode but debug flag is set' );
            }
        }

        //out = '$out/${app.platform}';
        //trace( out );
        //trace( Compiler.getOutput() );

        switch app.platform {
        case android:
            //out += '/assets';
            //trace( out );
            //Compiler.setOutput( '$out/app.js' );
            Compiler.define( 'mobile' );
            //Compiler.define( 'lib', 'om.android' );
        case electron:
            Compiler.define( 'desktop' );
        default:
        }

        meta = Meta.read();
        if( meta == null ) {
            meta = cast { build: 1, total: 1 }
        } else {
            meta.total++;
            if( meta.version < app.version ) {
                meta.build = 0;
            } else {
                meta.build++;
            }
        }

        meta.time = Date.now().toString();
        meta.version = app.version;

        app.version = app.version + '.' + meta.build;

        var clean = getDefine( 'clean' ) == '1';
        if( meta.platform != app.platform ) clean = true;

        meta.platform = app.platform;

        if( clean ) {
            FileUtil.deleteDirectory( out );
        }

        Compiler.define( app.platform );
        Compiler.define( 'platform', app.platform );

        Context.onAfterGenerate( function(){

            buildResources();
            buildStyle();
            buildHTML();
            buildPlatform();

            Meta.write( meta );

            var timeBuild = Time.stamp() - timeBuildStart;
            var timeBuildStr = Std.int( timeBuild ) / 1000;

            println( '${app.name}-${app.platform}-${app.version} | '+timeBuildStr );
            //println( '${app.name}-${app.platform}-${app.version}.${meta.build} | '+timeBuildStr );
        });
    }

    public static inline function warning( info : String, ?pos : Position ) {
        Context.warning( info, (pos == null) ? Context.currentPos() : pos );
    }

    public static inline function abort( error : String, ?pos : Position ) {
		Context.fatalError( error, (pos == null) ? Context.currentPos() : pos );
	}

    public static function getDefine<T>( key : String, ?def : T ) : T {
        key = DEFINE_PREFIX + key;
        return Context.defined( key ) ? cast Context.definedValue( key ) : def;
    }

    static function buildResources() {
        syncDirectory( '$res/font', '$out/font' );
        syncDirectory( '$res/icon', '$out/icon' );
        syncDirectory( '$res/image', '$out/image' );
        syncDirectory( '$res/mesh', '$out/mesh' );
        syncDirectory( '$res/script', '$out/script' );
        syncDirectory( '$res/sound', '$out/sound' );
    }

    static function buildStyle() {
        var lessFile = '$res/style/app.less';
        var cssFile = '$out/app.css';
        if( FileSystem.exists( lessFile ) )
            lessc( lessFile, cssFile );
    }

    static function buildHTML() {
        var file = 'index.html';
        var tpl = new Template( File.getContent( '$res/html/$file' ) );
        var html = tpl.execute( app, App );
        File.saveContent( '$out/$file', html );
    }

    /*
    static function display() {
        return "DISPLAY";
    }
    */

    static function buildPlatform() {

        switch app.platform {

        case android:
            //TODO

        //case atom:
            //TODO

        case chrome:
            //TODO

        case electron:
            syncFile( '$res/html/app.html', '$out/app.html' );
            syncFile( '$res/electron/package.json', '$out/package.json' );

        case web:
            syncFile( '$res/web/htaccess', '$out/.htaccess' );
            syncFile( '$res/html/index.html', '$out/index.html' );
            syncFile( '$res/web/manifest.json', '$out/manifest.json' );

        //case _:
        }
    }

    static function lessc( src : String, dst : String ) {
		var exe = new sys.io.Process( 'lessc', [src,dst] );
		switch exe.exitCode() {
		case 0:
			println( exe.stdout.readAll() );
		case _:
			println( exe.stderr.readAll() );
		}
	}

}

#end
