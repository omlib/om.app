package om.app;

class Storage {

    public var prefix(default,null) : String;

    public var length(get,null) : Int;
    inline function get_length() return storage.length;

    var storage : js.html.Storage;

    public function new( prefix = '' ) {
        this.prefix = prefix;
        storage = js.Browser.getLocalStorage();
    }

    public function get<T>( key : String ) : T {
        var item = storage.getItem( prefix + key );
        return (item == null) ? null : Json.parse( item );
    }

    public function set<T>( key : String, value : T ) {
        storage.setItem( prefix + key, Json.stringify( value ) );
    }

    public inline function key( index : Int ) : String {
        return storage.key( index );
    }

    public inline function clear() {
        storage.clear();
    }

}
