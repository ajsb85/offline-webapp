const Cc = Components.classes;
const Ci = Components.interfaces;

/** Modules to load **/
const modulesAll = [
'httpServer'
];

Components.utils.import("resource://gre/modules/XPCOMUtils.jsm");

var zContext = null;
var isFirstLoadThisSession = true;

AppContext = function() {}
AppContext.prototype = {
	
	"Cc":Cc,
	"Ci":Ci
	
};

/**
 * The class from which the App global XPCOM context is constructed
 *
 * @constructor
 * This runs when AppService is first requested to load all applicable scripts and initialize
 * App. Calls to other XPCOM components must be in here rather than in top-level code, as other
 * components may not have yet been initialized.
 */
function makeAppContext() {
	if(zContext) {
		// Swap out old zContext
		var oldzContext = zContext;
		// Create new zContext
		zContext = new AppContext();
		// Swap in old App object, so that references don't break, but empty it
		zContext.App = oldzContext.App;
		for(var key in zContext.App) delete zContext.App[key];
	} else {
		zContext = new AppContext();
		zContext.App = function() {};
	}
	
	// Load app.js first
	Cc["@mozilla.org/moz/jssubscript-loader;1"]
	.getService(Ci.mozIJSSubScriptLoader)
	.loadSubScript("chrome://app/content/app.js", zContext);
	
	// Load modules
	for (var i=0; i<modulesAll.length; i++) {
		try {
			Cc["@mozilla.org/moz/jssubscript-loader;1"]
			.getService(Ci.mozIJSSubScriptLoader)
			.loadSubScript("chrome://app/content/modules/" + modulesAll[i] + ".js", zContext);
		}
		catch (e) {
			Components.utils.reportError("Error loading " + modulesAll[i] + ".js", zContext);
			throw (e);
		}
	}
};

/**
 * The class representing the App service, and affiliated XPCOM goop
 */
function AppService() {
	try {
		var start = Date.now();
		
		if(isFirstLoadThisSession) {
			makeAppContext(false);
			try {
				zContext.App.init();
			} catch(e) {
				dump(e.toSource());
				Components.utils.reportError(e);
				throw e;
			}
		}
		isFirstLoadThisSession = false;
		this.wrappedJSObject = zContext.App;
		
		zContext.App.debug("Initialized in "+(Date.now() - start)+" ms");
	} catch(e) {
		var msg = typeof e == 'string' ? e : e.name;
		dump(e + "\n\n");
		Components.utils.reportError(e);
		throw e;
	}
}

AppService.prototype = {
	contractID: '@dapps/App;1',
	classDescription: 'App',
	classID: Components.ID('{d1931d9e-be49-4130-a386-a654314a973a}'),
	QueryInterface: XPCOMUtils.generateQI([Components.interfaces.nsISupports,
		Components.interfaces.nsIProtocolHandler])
}

/**
* XPCOMUtils.generateNSGetFactory was introduced in Mozilla 2 (Firefox 4).
* XPCOMUtils.generateNSGetModule is for Mozilla 1.9.2 (Firefox 3.6).
*/
if (XPCOMUtils.generateNSGetFactory) {
	var NSGetFactory = XPCOMUtils.generateNSGetFactory([AppService]);
} else {
	var NSGetModule = XPCOMUtils.generateNSGetModule([AppService]);
}
