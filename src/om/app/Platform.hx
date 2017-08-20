package om.app;

@:enum abstract Platform(String) from String to String {
    var android = 'android';
    //var atom = 'atom';
    var chrome = 'chrome';
    var electron = 'electron';
    var web = 'web';
}
