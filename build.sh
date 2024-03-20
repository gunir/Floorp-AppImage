#!/bin/bash

set -eux
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/Floorp-Projects/Floorp/releases > /tmp/version.json
cat /tmp/version.json| jq '.[0].assets[].browser_download_url' | grep floorp | grep linux-x86_64.tar.bz2
wget "$(cat /tmp/version.json| jq -r '.[0].assets[].browser_download_url' | grep floorp | grep linux-x86_64.tar.bz2)"
VERSION="$(cat /tmp/version.json| jq -r '.[0].tag_name')"

APPDIR=AppDir
#echo "$VERSION" >> $GITHUB_ENV
tar -xvf *.tar.* && rm -rf *.tar.*
mv floorp/* $APPDIR/
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x *.AppImage
echo "AppDir: $APPDIR"
ls -al
ls -al "$APPDIR"
ARCH=x86_64 ./appimagetool-x86_64.AppImage --comp gzip "$APPDIR" floorp.AppImage
mkdir dist
mv floorp.AppImage* dist/.
