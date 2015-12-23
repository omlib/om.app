package om;

import js.Browser.document;
import js.html.Element;
import om.app.Activity;

@:keep
@:build(om.app.macro.BuildApp.build())
@:autoBuild(om.app.macro.BuildApp.autoBuild())
class App {

    public var element(default,null) : Element;
    public var style(default,null) : om.app.Style;

    public function new( ?element : Element ) {

        if( element == null ) element = document.body;
        this.element = element;

        style = new om.app.Style();
    }

    public function init() {
    }

    @:access(om.app.Activity)
    function start( activity : Activity ) {
        activity.boot();
    }

    public function quit() {
    }
}
