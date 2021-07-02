#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

echo "building ..."
echo

# compact the namespace configuration schema
cat bash/json/namespace.schema.json | jq -c > bash/json/namespace.schema.min.json

# compact the actual namespace configuration into namespace.min.json
cat bash/namespace.json | jq -c > bash/namespace.min.json 

# validate the minified namespace configuration against the minified schema
ajv -s bash/json/namespace.schema.min.json -d bash/namespace.min.json 

echo
echo "build successful"
