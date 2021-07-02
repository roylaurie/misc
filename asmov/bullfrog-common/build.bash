#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

echo "building ..."
echo

rm -rf ./dist

# compact the namespace configuration schema
cat bash/json/namespace.schema.json | jq -c > bash/json/namespace.schema.min.json

# compact the actual namespace configuration into namespace.min.json
cat bash/namespace.json | jq -c > bash/namespace.min.json 

# validate the minified namespace configuration against the minified schema
ajv -s bash/json/namespace.schema.min.json -d bash/namespace.min.json 

mkdir ./dist
cp -r ./bash ./dist
cp -r ./config ./dist
cp -r ./json ./dist
cp -r ./skeleton ./dist

rm ./dist/json/namespace.json
rm ./dist/json/namespace.schema.json

echo
echo "build successful"
