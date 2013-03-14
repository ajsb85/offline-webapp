var browser;
function loadURI() {
	browser.loadURI.apply(browser, arguments);
}

window.addEventListener("load", function() {
	browser = document.getElementById('my-browser');
	
	browser.addEventListener("pageshow", function() {
		document.title = (browser.contentDocument.title
			? browser.contentDocument.title
			: browser.contentDocument.location.href);
	}, false);
	
	browser.loadURI.apply(browser, window.arguments);
	
	window.setTimeout(function() {
		document.getElementById("my-browser").style.overflow = "auto";
	}, 0);
}, false);
