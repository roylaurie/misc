#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset
cd "$(npm prefix)"

# compact the namespace configuration schema
jq -c < ./json/schema/namespace.schema.json > ./json/schema/namespace.schema.min.json

# compact the actual namespace configuration into namespace.min.json
jq -c < ./json/namespace.json > ./json/namespace.min.json

# validate the minified namespace configuration against the minified schema
ajv -s ./json/schema/namespace.schema.min.json -d ./json/namespace.min.json
