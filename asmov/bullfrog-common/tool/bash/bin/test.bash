#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset
cd "$(npm prefix)"

# shellcheck disable=SC2038  # warn on searching for non-alphanumeric file names
find ./bash -name '*.bash' | xargs shellcheck -P ./bash -P ./bash/lib > /dev/null ||
    echo "bash lint failed" &&
    exit 1

ajv -s ./json/schema/cfg/namespace.cfg.schema.json -d ./json/namespace.cfg.json