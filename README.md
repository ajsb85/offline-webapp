Dapps
-----------------------------
Dapps es una forma de realizar Webapps con solo un comando, para todas las plataformas (Mac, Windows, and Linux). El resultado final es una version offline de tu aplicacion web corriendo en una ventana personalizada.

Lo incluido en el paquete final:

* Una aplicacion minimalista hecha en XUL, la cual es solo una ventana tipo explorador.
* Un HTTP server (https://developer.mozilla.org/en-US/docs/Httpd.js/HTTP_server_for_unit_tests)
* XULRunner 18 (Gecko 18), aunque versiones anteriores tambien pueden funcionar.

Beneficios:
-----------------------------
* Soporte completo a HTML5 (El mismo que soporte que ofrece Firefox 18)
* Addons de Firefox pueden ser incluidos en tu WebApp
* Actualizacion de aplicaciones (https://developer.mozilla.org/en-US/docs/XULRunner/Application_Update)
* Modulos de server HTTP
* Es una aplicacion NATIVA!
* Trabaja sobre cualquier plataforma en donde corra Firefox 18, ventajas? Todas!
* Instalable desde USB / CD, Offline
* Uso Offline
* Facil testeo y debuging
* Ninguna dependencia de otras dependencias

Iniciando
-----------------------------
Comenzando a crear tu primera Webapp:

1. Copia este programa a una carpeta local
2. Agrega tu aplicacion en HTML5 en la carpeta /modules/dapps-webapp
3. Cambia la variable WEBAPPMODULE en el archivo config.sh con el nombre de la carpeta de tu Webapp que pusiste en /modules anteriormente, (por default esta la carpeta dapps-webapp)
4. Si es necesario, actualiza la url del navegador en modules/app/chrome/content/app/ui/main.xul
5. Modificar a gusto y demas ficheros
6. Teclea desde la terminal ./build.sh
7. Se generaran dos carpetas nuevas que son "dist" y "staging"
8. Have fun!

Tips
-----------------------------
### Haciendo Debugging a la aplicacion en XUL 
Revisa (https://developer.mozilla.org/en/docs/Debugging_a_XULRunner_Application). En Mac OSX, los parametros para xulrunner (como -jsconsole -P etc) puede ser ejecutado para Contents/MacOS/app script, como:

     Contents/MacOS/app -P -jsconsole

En Windows, creamos un icono para app.exe y agregamos los parametros en las propiedades del icono.

### Haciendo Debugging a la webapp
Esto es lo mejor de todo, desde que la funcion browser-view fue incluida en la webapp, puedes ver la aplicacion corriendo y acceder a ella desde http://localhost:57187.

### Haciendo Debugging a los scripts para la construccion
Agrega `set -x` al principio del archivo config.sh para ver todo lo que hace el script realiza en el proceso de construccion.

### Generando los iconos
Usa (http://iconverticons.com/) para generar iconos para todas las plataformas. Pon la imagen original en icons/default/source y las nuevas imagenes generadas en icons/default.

### Crear paquetes por versiones
Ejemplo, ya hemos lanzado las versiones 0.0.1, 0.0.2, 0.0.3 y 0.0.4, y la version 0.0.5 sera lanzada:

En OSX o Linux en la carpeta raiz de dapps, ejecuta:

     ./build-mac-and-linux-packages.sh 0.0.5

En Windows (Cygwin) en la carpeta raiz de dapps, ejecuta:

     ./build-windows-installer-package.sh 0.0.5

Esto producira los paquetes para Mac, Linux and Windows en el directorio "dist/0.0.5". Aqui lo podremos ofrecer a usuarios o clientes para que descarguen el paquete para actualizar.

AHora empezamos con los paquetes de actualizacion. Estos pueden ser generados desde un simple entorno de desderrollo (OSX, Linux or Windows). Para mas info y documentacion puedes leer (https://developer.mozilla.org/en-US/docs/XULRunner/Application_Update). Estos scripts, que se encuentran incluidos en este programa, pueden ser apliados desde aqui (https://wiki.mozilla.org/UpdateGeneration#What_the_Makefiles_do.2C_or_How_to_make_your_own_updates). Tambien es necesario saber como funciona el proceso de actualizaciones, y la forma en que se actualiza descargandolos desde la url que se puso en la variable PACKAGEURL en el fichero config.sh. Luego, ejecutamos:

     cd update-packaging/

     # Reset from earlier update packagings
     rm -rf dist/ # Clears dist directory
     if [ -h "staging/0.0.4" ]; then rm staging/0.0.4; fi # Clears previous symbolic link in staging directory

     # Build update packages
     ./build_autoupdate.sh 0.0.1 0.0.5
     ./build_autoupdate.sh 0.0.2 0.0.5
     ./build_autoupdate.sh 0.0.3 0.0.5
     ./build_autoupdate.sh 0.0.4 0.0.5

Esto producira los paquetes de actualizacion para Mac, Linux and Windows en la carpeta "update-packaging/dist". Estos paquetes tendran que ser hostados deacuerdo a como se plantea aqui (https://developer.mozilla.org/en-US/docs/Mozilla/Setting_up_an_update_server).

Changelog
-----------------------------

0.0.0.1 (2013-01-11)

 - Posible crear aplicaciones sin el borde de la Window
 - Tamaño personalizado de la ventana de la aplicacion
 - Facil manera de generar paquetes de aplicaciones
 - Crear los directorios staging y dist
 - Desactivado la cache en el disco
 - Los links con target="_blank" abren en una nueva ventana
 - Primera base

Creditos
-----------------------------
Este proyecto ha sido empezado y desarrollado por Giovanny Andres Gongora Granada y Miguel David Quintero

Licencia
-----------------------------
Dapps y los scripts son licenciados bajo la licencia [Definir licencia]. See COPYING for more details.
