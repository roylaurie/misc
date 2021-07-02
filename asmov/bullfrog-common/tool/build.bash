#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

echo "building ..."
echo

rm -rf ./dist

# compact the namespace configuration schema
cat json/schema/namespace.schema.json | jq -c > json/schema/namespace.schema.min.json

# compact the actual namespace configuration into namespace.min.json
cat json/namespace.json | jq -c > json/namespace.min.json 

# validate the minified namespace configuration against the minified schema
ajv -s json/schema/namespace.schema.min.json -d json/namespace.min.json 

mkdir ./dist
cp -r ./bash ./dist
cp -r ./config ./dist
cp -r ./json ./dist
cp -r ./skeleton ./dist

rm ./dist/json/namespace.json
rm ./dist/json/schema/namespace.schema.json

echo
echo "build successful"
