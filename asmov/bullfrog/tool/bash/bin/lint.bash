#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset
cd "$(npm prefix)"

# shellcheck disable=SC2038
find ./bash -name "*.bash" | xargs shellcheck || {
    echo "bash lint failed"
    exit 1
}

ajv -s ./json/schema/cfg/namespace.cfg.schema.json -d ./json/cfg/namespace.cfg.json