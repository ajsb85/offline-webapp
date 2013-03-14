# Listamos las plataformas
BUILD_MAC=1
BUILD_WIN32=1
BUILD_LINUX=1

# Hay plugins o Addons?
BUNDLE_PLUGINS=0

# Con que version de Gecko compilamos todo
GECKO_VERSION="	19.0.1"

# Rutas de xulrunner
MAC_RUNTIME_PATH="`pwd`/xulrunner/XUL.framework"
WIN32_RUNTIME_PATH="`pwd`/xulrunner/xulrunner_win32"
LINUX_i686_RUNTIME_PATH="`pwd`/xulrunner/xulrunner_linux-i686"
LINUX_x86_64_RUNTIME_PATH="`pwd`/xulrunner/xulrunner_linux-x86_64"

# Ruta para hacer una especie de out
# OUT=~

# El sign
SIGN=1

# OS X Developer ID
DEVELOPER_ID=dapps
CODESIGN_REQUIREMENTS="=designated => anchor apple generic  and identifier \"org.foo.bar\" and ((cert leaf[field.0.0.000.123456.000.1.2.3] exists) or ( certificate 1[field.1.0.000.123456.000.1.2.3] exists and certificate leaf[field.2.0.000.123456.000.1.2.3] exists  and certificate leaf[subject.OU] = \"FOO123BAR1\" ))"

# Rutas para Windows
MAKENSISU='C:\Program Files (x86)\NSIS\Unicode\makensis.exe'
UPX='C:\Program Files (x86)\upx\upx.exe'
EXE7ZIP='C:\Program Files\7-Zip\7z.exe'

# Rutas necesarias solo para el instalador pero certificado el paquete
SIGNTOOL='C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\signtool.exe'
SIGNATURE_URL='https://www.example.com/'

# Si la version no se especifica en el comando, nosotros le ponemos una
DEFAULT_VERSION_PREFIX="0.0.0.0.SOURCE."
# Version para el modulo para OS X
VERSION_NUMERIC="0.0.0.0"

# Directorio para la construccion
BUILDDIR="/tmp/app-build-`uuidgen | head -c 8`"
# Modulo a construir
MODULE="app"
# Modulos que contiene la webapp
WEBAPPMODULE="webapp"
# Directorio en donde se desempacan los binarios
STAGEDIR="$CALLDIR/out-unpackage"
# Directorio en donde estan los paquetes binarios
DISTDIR="$CALLDIR/out-package"

# Nombre de la aplicacion
APPNAME="Dapps WebApp"
PACKAGENAME="dapps-webapp"

# Url de donde se actualizan los paquetes
PACKAGESURL="http://www.example.com/app/packages"
