const MainUI = new function() {

	this.openAboutDialog = function() {
		window.openDialog('chrome://app/content/ui/about.xul', 'about', 'chrome');
	}

	this.checkForUpdates = function() {
		window.open('chrome://mozapps/content/update/updates.xul', 'updateChecker', 'chrome,centerscreen');
	}
	
}
