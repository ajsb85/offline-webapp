// Aqui va la URL en donde todo iniciara
pref("toolkit.defaultChromeURI", "chrome://app/content/ui/main.xul");

// Solo es necesaria una ventana, no?
pref("toolkit.singletonWindowType", "navigator:browser");

// Esto es solo para hacer debugging , me parece importante que lo tengamos activado
pref("javascript.options.showInConsole", true);

// No devuelve los links cuando piden traduccion
pref("network.prefetch-next", false);

// Aqui simplemente permitimos que las operaciones corran tanto como sean necesarias
pref("dom.max_chrome_script_run_time", 0);

// Habilitamos JaegerMonkey, todo es para un proximo testing
pref("javascript.options.methodjit.chrome", true);

// Usamos OS locale
pref("intl.locale.matchOS", true);

// Usamos un simple basicViewer para abrir una ventana DOM
pref("browser.chromeURL", "chrome://app/content/ui/basicViewer.xul");
// Eso es necesario para guardar el dialogo en contentAreaUtils.js
pref("browser.download.useDownloadDir", false);
pref("browser.download.manager.showWhenStarting", true);
pref("browser.download.folderList", 1);
pref("browser.download.manager.retention", 1);

// No muestrar el cuadro de seleccion de Addons, pero si lo usamos :)
pref("extensions.shownSelectionUI", true);
pref("extensions.autoDisableScope", 11);

// Nunca mas offline
pref("offline.autoDetect", false);
pref("network.manage-offline-status", false);

// Desactivamos la aceleracion de graficos, no la necesitamos
pref("layers.acceleration.disabled", true);
pref("gfx.direct2d.disabled", true);

// Sin esto, podriamos tener muchos Pop-Up's preguntandonos si queremos traducir
pref("browser.xul.error_pages.enabled", true);

// Sin esto, se habriran Pop-Up's
pref("dom.disable_open_during_load", true);

// Esto es acerca de las conecciones seguras
pref("security.warn_viewing_mixed", false);

// Preferencias de los addons
pref("extensions.getAddons.cache.enabled", false);
//pref("extensions.getAddons.maxResults", 15);
//pref("extensions.getAddons.get.url", "https://services.addons.mozilla.org/%LOCALE%/%APP%/api/%API_VERSION%/search/guid:%IDS%?src=thunderbird&appOS=%OS%&appVersion=%VERSION%&tMain=%TIME_MAIN%&tFirstPaint=%TIME_FIRST_PAINT%&tSessionRestored=%TIME_SESSION_RESTORED%");
//pref("extensions.getAddons.search.browseURL", "https://addons.mozilla.org/%LOCALE%/%APP%/search?q=%TERMS%");
//pref("extensions.getAddons.search.url", "https://services.addons.mozilla.org/%LOCALE%/%APP%/api/%API_VERSION%/search/%TERMS%/all/%MAX_RESULTS%/%OS%/%VERSION%?src=thunderbird");

// Habilitar instalar XPIs de cualquier parte
pref("xpinstall.whitelist.required", false);

// Desactivamos lugares
pref("places.history.enabled", false);

/**Importado desde https://developer.mozilla.org/en/XULRunner/Application_Update **/
// Sea como sea las actualizaciones estan activadas
pref("app.update.enabled", true);

// Aqui hacemos que todo se actualice automaticamente
pref("app.update.auto", true);

// Define como la aplicacion notifica la actualizacion:
//
// AUM Set to:        Minor Releases:     Major Releases:
// 0                  download no prompt  download no prompt
// 1                  download no prompt  download no prompt if no incompatibilities
// 2                  download no prompt  prompt
//
// En nsUpdateService.js.in se pueden ver mas detalles
//
pref("app.update.mode", 2);

// Si se pone true, cuando actualice no se mostrara en la UI
pref("app.update.silent", false);
pref("app.update.showInstalledUI", true);

// Esto lo tenemos que daclarar con la documentacion en MDN
pref("app.update.url", "https://www.example.com/app/update/%VERSION%/%BUILD_ID%/%BUILD_TARGET%/%LOCALE%/%CHANNEL%/%OS_VERSION%/update.xml");

// Actualizacion manual?
pref("app.update.url.manual", "http://www.example.com/app/");

// Detalles de la actualizacion
pref("app.update.url.details", "http://www.example.com/app/changelog");

// Esto es para propositos de testing no mas
//           default=1 day
pref("app.update.interval", 86400);

// Interval: Tiempo antes de que un usuario descargue una nueva version
//           default=1 day
pref("app.update.nagTimer.download", 86400);

// Interval: Tiempo antes de que el usuario necesite reiniciar para 
//           instalar la ultima actualizacion
//           default=30 minutes
pref("app.update.nagTimer.restart", 1800);

// Tiempo minimo para el lanzar
// default=2 minutes
pref("app.update.timerMinimumDelay", 120);

// Mostrar que la aplicacion se ha actualizado
pref("app.update.showInstalledUI", false);

// 0 = Suprimir incopatibilidades is estan habilitadas como actualizaciones,
//     esto podra ser solucionado por nuevas versiones de los Addons.
// 1 = Suprimir incopatibilidades si solo se encuentran en VersionInfo
pref("app.update.incompatible.mode", 0);

// Remplazar el canal de actualizacion :)
pref("app.update.channel", "replaced-by-build-script");

// Suprimir advertencias de los navegadores, no las necesitamos
pref("network.protocol-handler.warn-external.http", false);
pref("network.protocol-handler.warn-external.https", false);
pref("network.protocol-handler.warn-external.ftp", false);

// Desabilitar la cache en el disco, porque necesitamos actualizar :)
pref("browser.cache.disk.enable", false);

// Solucionando problemas con la cache
pref("browser.dom.window.dump.enabled", true);
pref("javascript.options.showInConsole", true);
pref("javascript.options.strict", true);
pref("nglayout.debug.disable_xul_cache", true);
pref("nglayout.debug.disable_xul_fastload", true);
pref("extensions.getAddons.cache.enabled", false);
