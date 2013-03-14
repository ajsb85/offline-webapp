#!/bin/bash

CALLDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$CALLDIR/config.sh"

[ "`uname`" != "Darwin" ]
MAC_NATIVE=$?
[ "`uname -o 2> /dev/null`" != "Cygwin" ]
WIN_NATIVE=$?

function usage {
	cat >&2 <<DONE
Usage: $0 [-p PLATFORMS] [-s DIR] [-v VERSION] [-c CHANNEL] [-d]
Options
 -p PLATFORMS        build for platforms PLATFORMS (m=Mac, w=Windows, l=Linux)
 -v VERSION          use version VERSION
 -c CHANNEL          use update channel CHANNEL
 -d                  don't package; only build binaries in staging/ directory
DONE
	exit 1
}

PACKAGE=1
while getopts "p:s:v:c:d" opt; do
	case $opt in
		p)
			BUILD_MAC=0
			BUILD_WIN32=0
			BUILD_LINUX=0
			for i in `seq 0 1 $((${#OPTARG}-1))`
			do
				case ${OPTARG:i:1} in
					m) BUILD_MAC=1;;
					w) BUILD_WIN32=1;;
					l) BUILD_LINUX=1;;
					*)
						echo "$0: Invalid platform option ${OPTARG:i:1}"
						usage
						;;
				esac
			done
			;;
		s)
			SYMLINK_DIR="$OPTARG"
			PACKAGE=0
			;;
		v)
			VERSION="$OPTARG"
			;;
		c)
			UPDATE_CHANNEL="$OPTARG"
			;;
		d)
			PACKAGE=0
			;;
		*)
			usage
			;;
	esac
	shift $((OPTIND-1)); OPTIND=1
done

if [ ! -z $1 ]; then
	usage
fi

BUILDID=`date +%Y%m%d`

shopt -s extglob
mkdir "$BUILDDIR"

if [ ! -d "$STAGEDIR" ]; then mkdir -p "$STAGEDIR"; fi

if [ -z "$UPDATE_CHANNEL" ]; then UPDATE_CHANNEL="default"; fi

	echo "Building standalone version of '$WEBAPPMODULE'"

	cp -RH "$CALLDIR/include/$MODULE" "$BUILDDIR/$MODULE"
	cd "$CALLDIR/include/$MODULE"
	REV=`git log -n 1 --pretty='format:%h'`

	if [ -z "$VERSION" ]; then
		VERSION="$DEFAULT_VERSION_PREFIX$REV"
	fi
	
	DISTDIR="$DISTDIR/$VERSION"

	if [ ! -d "$DISTDIR" ]; then mkdir -p "$DISTDIR"; fi

	cp -R "$CALLDIR/config/branding" "$BUILDDIR/$MODULE/chrome/branding"
	
	find "$BUILDDIR/$MODULE" -depth -type d -name .git -exec rm -rf {} \;
	find "$BUILDDIR/$MODULE" -name .DS_Store -exec rm -f {} \;
	
	cd "$BUILDDIR/$MODULE/chrome"
	if [ $? -eq 1 ]; then
		exit;
	fi
	zip -0 -r -q ../$MODULE.jar .
	rm -rf "$BUILDDIR/$MODULE/chrome/"*
	mv ../$MODULE.jar .
	cd ..
		
	echo "" >> "$BUILDDIR/$MODULE/chrome.manifest"
	cat "$CALLDIR/config/chrome.manifest" >> "$BUILDDIR/$MODULE/chrome.manifest"
	
	cp "$CALLDIR/config/updater.ini" "$BUILDDIR/$MODULE"
	
	perl -pi -e 's/chrome\//jar:chrome\/'$MODULE'.jar\!\//g' "$BUILDDIR/$MODULE/chrome.manifest"

cp -r "$CALLDIR/config/icons" "$BUILDDIR/$MODULE/chrome/icons"

cp -r "$CALLDIR/include/$WEBAPPMODULE/" "$BUILDDIR/$MODULE/chrome/webapp/"

cp "$CALLDIR/config/application.ini" "$BUILDDIR/application.ini"
perl -pi -e "s/{{VERSION}}/$VERSION/" "$BUILDDIR/application.ini"
perl -pi -e "s/{{BUILDID}}/$BUILDID/" "$BUILDDIR/application.ini"

cp "$CALLDIR/config/prefs.js" "$BUILDDIR/$MODULE/defaults/preferences"
perl -pi -e 's/pref\("app\.update\.channel", "[^"]*"\);/pref\("app\.update\.channel", "'"$UPDATE_CHANNEL"'");/' "$BUILDDIR/$MODULE/defaults/preferences/prefs.js"
perl -pi -e 's/%GECKO_VERSION%/'"$GECKO_VERSION"'/g' "$BUILDDIR/$MODULE/defaults/preferences/prefs.js"

find "$BUILDDIR" -depth -type d -name .git -exec rm -rf {} \;
find "$BUILDDIR" -name .DS_Store -exec rm -f {} \;

cd "$CALLDIR"

if [ $BUILD_MAC == 1 ]; then
	echo "Building $APPNAME.app"
		
	APPDIR="$STAGEDIR/$APPNAME.app"
	rm -rf "$APPDIR"
	mkdir "$APPDIR"
	chmod 755 "$APPDIR"
	cp -r "$CALLDIR/mac/Contents" "$APPDIR"
	CONTENTSDIR="$APPDIR/Contents"
	
	mkdir "$CONTENTSDIR/MacOS"
	mkdir "$CONTENTSDIR/Resources"
	cp -a "$MAC_RUNTIME_PATH/Versions/Current"/* "$CONTENTSDIR/MacOS"
	mv "$CONTENTSDIR/MacOS/xulrunner" "$CONTENTSDIR/MacOS/$MODULE-bin"
	cp "$CALLDIR/mac/$MODULE" "$CONTENTSDIR/MacOS/$MODULE"
	mv "$CONTENTSDIR/MacOS/updater.app/Contents/MacOS/updater" "$CONTENTSDIR/MacOS/updater.app/Contents/MacOS/updater-bin"
	cp "$CALLDIR/mac/updater" "$CONTENTSDIR/MacOS/updater.app/Contents/MacOS/updater"
	cp "$BUILDDIR/application.ini" "$CONTENTSDIR/Resources/"
	cp "$CALLDIR/mac/Contents/Info.plist" "$CONTENTSDIR"
	cp "$CALLDIR/config/icons/default/default.icns" "$CONTENTSDIR/Resources/$MODULE.icns"
	
	if [ $BUNDLE_PLUGINS == 1 ]; then
		mkdir -p "$CONTENTSDIR/Resources/addons/"
		cp -r "$CALLDIR/addons/mac/"* "$CONTENTSDIR/Resources/addons/"
	fi

	cp "$CALLDIR/mac/Contents/Info.plist" "$CONTENTSDIR/Info.plist"
	perl -pi -e "s/{{VERSION}}/$VERSION/" "$CONTENTSDIR/Info.plist"
	perl -pi -e "s/{{VERSION_NUMERIC}}/$VERSION_NUMERIC/" "$CONTENTSDIR/Info.plist"
	rm -f "$CONTENTSDIR/Info.plist.bak"
	
	cp -R "$BUILDDIR/$MODULE/"* "$CONTENTSDIR/Resources"
	
	cd "$CALLDIR/config/mac"
	zip -0 -r -q "$CONTENTSDIR/Resources/chrome/$MODULE.jar" *
	
	find "$CONTENTSDIR" -depth -type d -name .git -exec rm -rf {} \;
	find "$CONTENTSDIR" \( -name .DS_Store -or -name update.rdf \) -exec rm -f {} \;
	
	if [ $SIGN == 1 ]; then
		/usr/bin/codesign --force --sign "$DEVELOPER_ID" \
			--requirements "$CODESIGN_REQUIREMENTS" \
			"$APPDIR"
	fi
	
	if [ $PACKAGE == 1 ]; then
		if [ $MAC_NATIVE == 1 ]; then
			rm -f "$DISTDIR/${PACKAGENAME}-${VERSION}.dmg"
			echo 'Creating Mac installer'
			"$CALLDIR/mac/pkg-dmg" --source "$STAGEDIR/$APPNAME.app" \
				--target "$DISTDIR/${PACKAGENAME}-${VERSION}.dmg" \
				--sourcefile --volname "$APPNAME" --copy "$CALLDIR/mac/DSStore:/.DS_Store" \
				--symlink /Applications:"/Drag Here to Install" > /dev/null
		else
			echo 'Not building on Mac; creating Mac distribution as a zip file'
			rm -f "$DISTDIR/${PACKAGENAME}-${VERSION}-mac.zip"
			cd "$STAGEDIR" && zip -rqX "$DISTDIR/${PACKAGENAME}-${VERSION}-mac.zip" $APPNAME.app
		fi
	fi
fi

if [ $BUILD_WIN32 == 1 ]; then
	echo "Building ${PACKAGENAME}-win32"
	
	APPDIR="$STAGEDIR/${PACKAGENAME}-win32"
	rm -rf "$APPDIR"
	mkdir "$APPDIR"
	
	if [ $BUNDLE_PLUGINS == 1 ]; then
		mkdir -p "$APPDIR/addons"
		cp -r "$CALLDIR/addons/win32/"* "$APPDIR/addons/"
	fi

	cp -R "$BUILDDIR/$MODULE/"* "$BUILDDIR/application.ini" "$APPDIR"
	cp -r "$WIN32_RUNTIME_PATH" "$APPDIR/xulrunner"
	
	mv "$APPDIR/xulrunner/xulrunner-stub.exe" "$APPDIR/${APPNAME}.exe"
	
	cp "$WIN32_RUNTIME_PATH/msvcp100.dll" \
	   "$WIN32_RUNTIME_PATH/msvcr100.dll" \
	   "$APPDIR/"
	
	cd "$CALLDIR/config/win"
	zip -0 -r -q "$APPDIR/chrome/$MODULE.jar" *
	
	rm "$APPDIR/xulrunner/js.exe" "$APPDIR/xulrunner/redit.exe"
	find "$APPDIR" -depth -type d -name .git -exec rm -rf {} \;
	find "$APPDIR" \( -name .DS_Store -or -name update.rdf \) -exec rm -f {} \;
	find "$APPDIR" \( -name '*.exe' -or -name '*.dll' \) -exec chmod 755 {} \;
	
	if [ $PACKAGE == 1 ]; then
		if [ $WIN_NATIVE == 1 ]; then
			INSTALLER_PATH="$DISTDIR/${PACKAGENAME}-${VERSION}-setup.exe"
			
			"$CALLDIR/win/ReplaceVistaIcon/ReplaceVistaIcon.exe" "`cygpath -w \"$APPDIR/${APPNAME}.exe\"`" \
				"`cygpath -w \"$CALLDIR/config/icons/default/main-window.ico\"`"
			
			echo 'Creating Windows installer'
			cp -r "$CALLDIR/win/installer" "$BUILDDIR/win_installer"
			
			"`cygpath -u \"$MAKENSISU\"`" /V1 "`cygpath -w \"$BUILDDIR/win_installer/uninstaller.nsi\"`"
			mkdir "$APPDIR/uninstall"
			mv "$BUILDDIR/win_installer/helper.exe" "$APPDIR/uninstall"
			
			if [ $SIGN == 1 ]; then
				"`cygpath -u \"$SIGNTOOL\"`" sign /a /d "$APPNAME" \
					/du "$SIGNATURE_URL" "`cygpath -w \"$APPDIR/${APPNAME}.exe\"`"
				"`cygpath -u \"$SIGNTOOL\"`" sign /a /d "$APPNAME Updater" \
					/du "$SIGNATURE_URL" "`cygpath -w \"$APPDIR/xulrunner/updater.exe\"`"
				"`cygpath -u \"$SIGNTOOL\"`" sign /a /d "$APPNAME Uninstaller" \
					/du "$SIGNATURE_URL" "`cygpath -w \"$APPDIR/uninstall/helper.exe\"`"
			fi
			
			INSTALLERSTAGEDIR="$BUILDDIR/win_installer/staging"
			mkdir "$INSTALLERSTAGEDIR"
			cp -R "$APPDIR" "$INSTALLERSTAGEDIR/core"
			
			perl -pi -e "s/{{VERSION}}/$VERSION/" "$BUILDDIR/win_installer/defines.nsi"
			"`cygpath -u \"$MAKENSISU\"`" /V1 "`cygpath -w \"$BUILDDIR/win_installer/installer.nsi\"`"
			mv "$BUILDDIR/win_installer/setup.exe" "$INSTALLERSTAGEDIR"
			if [ $SIGN == 1 ]; then
				"`cygpath -u \"$SIGNTOOL\"`" sign /a /d "$APPNAME Setup" \
					/du "$SIGNATURE_URL" "`cygpath -w \"$INSTALLERSTAGEDIR/setup.exe\"`"
			fi
			
			cd "$INSTALLERSTAGEDIR" && "`cygpath -u \"$EXE7ZIP\"`" a -r -t7z "`cygpath -w \"$BUILDDIR/app_win32.7z\"`" \
				-mx -m0=BCJ2 -m1=LZMA:d24 -m2=LZMA:d19 -m3=LZMA:d19  -mb0:1 -mb0s1:2 -mb0s2:3 > /dev/null
				
			"`cygpath -u \"$UPX\"`" --best -o "`cygpath -w \"$BUILDDIR/7zSD.sfx\"`" \
				"`cygpath -w \"$CALLDIR/win/installer/7zstub/firefox/7zSD.sfx\"`" > /dev/null
			
			cat "$BUILDDIR/7zSD.sfx" "$CALLDIR/win/installer/app.tag" \
				"$BUILDDIR/app_win32.7z" > "$INSTALLER_PATH"
			
			if [ $SIGN == 1 ]; then
				"`cygpath -u \"$SIGNTOOL\"`" sign /a /d "$APPNAME Setup" \
					/du "$SIGNATURE_URL" "`cygpath -w \"$INSTALLER_PATH\"`"
			fi
			
			chmod 755 "$INSTALLER_PATH"
		else
			echo 'Not building on Windows; only building zip file'
		fi
		cd "$STAGEDIR" && zip -rqX "$DISTDIR/${PACKAGENAME}-${VERSION}-win32.zip" "${PACKAGENAME}-win32"
	fi
fi

if [ $BUILD_LINUX == 1 ]; then
	for arch in "i686" "x86_64"; do
		RUNTIME_PATH=`eval echo '$LINUX_'$arch'_RUNTIME_PATH'`
		
		echo "Building ${PACKAGENAME}-linux-$arch"
		APPDIR="$STAGEDIR/${PACKAGENAME}-linux-$arch"
		rm -rf "$APPDIR"
		mkdir "$APPDIR"

		if [ $BUNDLE_PLUGINS == 1 ]; then
			mkdir -p "$APPDIR/addons"
			cp -r "$CALLDIR/addons/linux-$arch/"* "$APPDIR/addons/"
		fi

		cp -R "$BUILDDIR/$MODULE/"* "$BUILDDIR/application.ini" "$APPDIR"
		cp -r "$RUNTIME_PATH" "$APPDIR/xulrunner"
		mv "$APPDIR/xulrunner/xulrunner-stub" "$APPDIR/$MODULE"
		chmod 755 "$APPDIR/$MODULE"
	
		cd "$CALLDIR/config/unix"
		zip -0 -r -q "$APPDIR/chrome/$MODULE.jar" *
		
		find "$APPDIR" -depth -type d -name .git -exec rm -rf {} \;
		find "$APPDIR" \( -name .DS_Store -or -name update.rdf \) -exec rm -f {} \;
		
		cp "$CALLDIR/linux/run-$MODULE.sh" "$APPDIR/run-$MODULE.sh"
		
		mv "$APPDIR/xulrunner/icons" "$APPDIR/icons"
		
		if [ $PACKAGE == 1 ]; then
			rm -f "$DISTDIR/${PACKAGENAME}-${VERSION}-linux-$arch.tar.bz2"
			cd "$STAGEDIR"
			tar -cjf "$DISTDIR/${PACKAGENAME}-${VERSION}-linux-$arch.tar.bz2" "${PACKAGENAME}-linux-$arch"
		fi
	done
fi

rm -rf $BUILDDIR
