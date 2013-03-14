(function(){

	// Privileged (public) methods
	this.init = init;
	this.getWebAppDirectory = getWebAppDirectory;
	this.getRootPrefBranch = getRootPrefBranch;
	this.debug = debug;
	
	// Public properties
	this.initialized = false;
	this.version = null;
	this.build = null;
	
	/**
	 * Initialize the wrapper
	 */
	function init() {
		if (this.initialized) {
			return false;
		}
		
		var appInfo = Components.classes["@mozilla.org/xre/app-info;1"].
		getService(Components.interfaces.nsIXULAppInfo),
		platformVersion = appInfo.platformVersion;

		this.version = appInfo.version;
		this.build = appInfo.appBuildID;
		
		if(!_initModules()) return false;
		this.initComplete();
		
		return true;
	}
	
	/**
	 * Triggers events when initialization finishes
	 */
	this.initComplete = function() {
		if(this.initialized) return;
		this.initialized = true;
	}
	
	/**
	 * Initialize modules
	 */
	function _initModules() {
		if(getRootPrefBranch().getBoolPref("app.httpServer.enabled")) {
			App.HttpServer.init();
		}
		return true;
	}

	function getWebAppDirectory() {

		var file = Components.classes["@mozilla.org/file/directory_service;1"].
		getService(Components.interfaces.nsIProperties).
		get("AChrom", Components.interfaces.nsIFile);
		file.append("webapp");
		return file;

	}

	var gRootPrefBranch = null;
	function getRootPrefBranch()
	{
		if (!gRootPrefBranch)
		{
			gRootPrefBranch = Cc["@mozilla.org/preferences-service;1"]
			.getService(Ci.nsIPrefBranch);
		}
		return gRootPrefBranch;
	}

	function debug(msg) {
		dump(msg + "\n");
	}

}).call(App);



