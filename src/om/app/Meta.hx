package om.app;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef Data = {
    var build : Int;
    var time : Float;
    var version : String;
    var total : Int;
}

class Meta {

    public static inline var DIR = '.om';
    public static inline var BUILD_INFO = '$DIR/build.json';

    public static function read() : Data {
        if( !FileSystem.exists( BUILD_INFO ) )
            return null;
        return Json.parse( File.getContent( BUILD_INFO ) );
    }

    public static function write( data : Data ) {
        if( !FileSystem.exists( DIR ) ) FileSystem.createDirectory( DIR );
        File.saveContent( BUILD_INFO, Json.stringify( data ) );
    }

}
