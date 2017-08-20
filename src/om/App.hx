package om;

#if macro

import haxe.macro.Context;
import om.app.Platform;

using om.Path;

class App {

    public var name : String;
    public var version : String;
    public var platform : Platform;

    public var debug : Bool;
    public var release : Bool;

    public var description : String;
    public var author : String;

    public function new( name : String, version : String, platform : String ) {
        this.name = name;
        this.version = version;
        this.platform = platform;
    }
}

#else

@:autoBuild(om.macro.BuildApp.complete())
interface App {}

#end
