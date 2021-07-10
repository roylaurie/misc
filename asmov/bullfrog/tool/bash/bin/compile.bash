#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset
cd "$(npm prefix)"

# compact the namespace configuration schema
jq -c < ./json/schema/cfg/namespace.cfg.schema.json > ./json/schema/cfg/namespace.cfg.schema.min.json

# compact the actual namespace configuration into namespace.cfg.json
jq -c < ./json/cfg/namespace.cfg.json > ./json/cfg/namespace.cfg.min.json

# validate the minified namespace configuration against the minified schema
ajv -s ./json/schema/cfg/namespace.cfg.schema.min.json -d ./json/cfg/namespace.cfg.min.json

# convert json into the frogcfg bash script
./tool/js/json2bash.mjs \
    ./json/schema/cfg/namespace.cfg.schema.min.json \
    ./json/cfg/namespace.cfg.min.json \
    > ./bash/cfg/namespace.cfg.bash

