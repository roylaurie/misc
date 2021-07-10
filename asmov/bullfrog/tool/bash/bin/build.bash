#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 
cd "$(npm prefix)"

FROG_VERSION="$(cat config/frog-version.txt)"
FROG_ARCH="amd64"

echo -e "building bullfrog ...\n"

rm -rf ./dist
mkdir -p ./dist/bullfrog

_rsyncExcludes="--exclude "*.swp" --exclude="*.swo""
rsync -a ./bash ./dist/bullfrog $_rsyncExcludes
rsync -a ./config ./dist/bullfrog $_rsyncExcludes
rsync -a ./json ./dist/bullfrog $_rsyncExcludes
rsync -a ./files ./dist/bullfrog $_rsyncExcludes

# remove source json where minified
mv ./dist/bullfrog/json/cfg/namespace.cfg.min.json ./dist/bullfrog/json/cfg/namespace.cfg.json
mv ./dist/bullfrog/json/schema/cfg/namespace.cfg.schema.min.json ./dist/bullfrog/json/schema/cfg/namespace.cfg.schema.json

# build the debian package
mkdir -p ./dist/debian/bullfrog/usr/local/lib ./dist/debian/bullfrog/usr/local/bin
rsync -a ./tool/files/package/debian/DEBIAN ./dist/debian/bullfrog $_rsyncExcludes
rsync -a ./dist/bullfrog ./dist/debian/bullfrog/usr/local/lib $_rsyncExcludes
ln -s ../lib/bullfrog/bash/bin/bullfrog.bash ./dist/debian/bullfrog/usr/local/bin/bullfrog

dpkg-deb --build ./dist/debian/bullfrog

dpkgFilename="bullfrog-${FROG_VERSION}-${FROG_ARCH}.deb"
mv ./dist/debian/bullfrog.deb ./dist/$dpkgFilename
cp -f ./dist/$dpkgFilename ./files/debian-package
rm -rf ./dist/debian

echo
echo "build successful"
