#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

echo "building ..."
echo

cd $(npm prefix)

rm -rf ./dist

# compact the namespace configuration schema
cat ./json/schema/namespace.schema.json | jq -c > ./json/schema/namespace.schema.min.json

# compact the actual namespace configuration into namespace.min.json
cat ./json/namespace.json | jq -c > ./json/namespace.min.json 

# validate the minified namespace configuration against the minified schema
ajv -s ./json/schema/namespace.schema.min.json -d ./json/namespace.min.json 

mkdir -p ./dist/bullfrog-common

_rsyncExcludes="--exclude "*.swp" --exclude="*.swo""
rsync -a ./bash ./dist/bullfrog-common $_rsyncExcludes
rsync -a ./config ./dist/bullfrog-common $_rsyncExcludes
rsync -a ./json ./dist/bullfrog-common $_rsyncExcludes
rsync -a ./skeleton ./dist/bullfrog-common $_rsyncExcludes

# remove source json where minified
rm ./dist/bullfrog-common/json/namespace.json
rm ./dist/bullfrog-common/json/schema/namespace.schema.json

# build the debian package
mkdir -p ./dist/debian/bullfrog-common/usr/local/lib ./dist/debian/bullfrog-common/usr/local/bin
rsync -a ./tool/build/DEBIAN ./dist/debian/bullfrog-common $_rsyncExcludes
rsync -a ./dist/bullfrog-common ./dist/debian/bullfrog-common/usr/local/lib $_rsyncExcludes
ln -s ../lib/bullfrog-common/bash/bin/bullfrog.bash ./dist/debian/bullfrog-common/usr/local/bin/bullfrog
dpkg-deb --build ./dist/debian/bullfrog-common
mv ./dist/debian/bullfrog-common.deb ./dist/bullfrog-common-0.0.amd64.deb
rm -rf ./dist/debian

echo
echo "build successful"
