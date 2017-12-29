package om;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.format.JsonPrinter;
import om.Res;

using om.Path;

class App {

    public static inline var BIN = 'bin';
    public static inline var RES = 'res';

    static var context : Dynamic;

    static function complete() : Array<Field> {
        var fields = Context.getBuildFields();
        return fields;
    }

    static function __init__() {

        var path = Fs.cwd();
        var name = getDefine( 'om_app_name', path.withoutDirectory() );
        var version = getDefine( 'om_app_version', '0.0.0' );

        var platform = getDefine( 'om_app_platform' );
        if( platform == null ) platform = if( isDefined( 'android' ) || isDefined( 'om_android' ) ) 'android';
            else if( isDefined( 'electron' ) ) 'electron';
            else 'web';

        context = {
            name : name,
            version: version,
            debug: isDefined( 'debug' ),
            release: isDefined( 'release' ),
            platform: platform
        };

        if( context.release ) {
            if( context.debug )
                Context.warning( 'debug flag set in release mode', Context.currentPos() );

        }

        if( context.debug ) {
        }

        var clean = isDefined( 'clean' );
        if( clean ) {
            Fs.deleteDirectoryRecursive( BIN );
        }

        /*
        var meta : Dynamic;
        if( Fs.exists( '.om/build.json' ) ) {
            meta = Json.parse( Fs.getContent( '.om/build.json' ) );
            meta.build++;
        } else {
            meta = {};
            for( f in Reflect.fields( context ) )
                Reflect.setField( meta, f, Reflect.field( context, f ) );
            meta.build = 0;
        }
        //trace(meta); 
        */

        //om.Res.init( RES );

        Context.onAfterGenerate( function(){

            //Template.globals = context;

            //Context.registerModuleDependency( 'gamma.App', 'res/style/app.less' );

            /*
            var style = Res.find( 'style', ['app',name] );
            if( style != null ) {
                //trace(style);
            }
            */

            switch platform {
            case 'android':
                Res.build( 'html', 'app', 'app.html', context );
            case 'electron':
                Res.build( 'html', 'app', 'app.html', context );
                Res.build( 'electron', 'package.json', 'package.json', context );
            case 'web':
                Res.build( 'html', 'app', 'index.html', context );
            }

            //if( !Fs.exists( '.om' ) ) Fs.createDirectory( '.om' );
            //Fs.saveContent( '.om/build.json', JsonPrinter.print( meta, '\t' ) );

            Sys.println( '${context.name}-${context.platform}-${context.version}' );
        });
    }

    static function isDefined( key : String, default_ = false, prefix = true ) : Bool {
        return Context.defined( key ) ? true : default_;
    }

    static function getDefine<T>( key : String, ?default_ : T, prefix = true ) : T {
        return Context.defined( key ) ? cast Context.definedValue( key ) : default_;
    }

}

#else
@:autoBuild(om.App.complete())
interface App {}
#end
