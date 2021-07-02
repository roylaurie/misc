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

_rsyncExcludes="--exclude "*.swp""
rsync -a ./bash ./dist/bullfrog-common $_rsyncExcludes
rsync -a ./config ./dist/bullfrog-common $_rsyncExcludes
rsync -a ./json ./dist/bullfrog-common $_rsyncExcludes
rsync -a ./skeleton ./dist/bullfrog-common $_rsyncExcludes

# remove source json where minified
rm ./dist/bullfrog-common/json/namespace.json
rm ./dist/bullfrog-common/json/schema/namespace.schema.json

echo
echo "build successful"
