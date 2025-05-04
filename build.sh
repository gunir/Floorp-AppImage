#!/bin/sh

set -eux
export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
APPDIR="$(realpath ./AppDir)"
APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-"$ARCH".AppImage"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"

FLOORP_URL="$(wget -q https://api.github.com/repos/floorp-Projects/Floorp/releases/latest -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi "https.*linux-$ARCH.tar.bz2$" | head -1)"
VERSION="$(echo $FLOORP_URL | awk -F"/" '{print $(NF-1)}')"

wget --retry-connrefused --tries=30 "$FLOORP_URL"
wget --retry-connrefused --tries=30 "$APPIMAGETOOL" -O ./appimagetool
tar -xvf *.tar.* && rm -f *.tar.*
mv floorp/* "$APPDIR"/
chmod +x ./AppDir/AppRun ./appimagetool
echo "AppDir: $APPDIR"
ls -al
ls -al "$APPDIR"
./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n -u "$UPINFO" "$APPDIR" floorp-"$VERSION"-"$ARCH".AppImage
mkdir dist
mv *.AppImage* dist/.
