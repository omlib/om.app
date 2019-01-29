package om.app;

enum abstract Platform(String) from String to String {

	var Android = "android";
    var Chrome = "chrome";
    var Electron = "electron";
    var Web = "web";

	/*
	public static inline var THIS =
		#if android Android
		#elseif chrome_app Chrome
		#elseif electron Electron
		#else Web
		#end;
		*/
}
