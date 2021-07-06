#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

frogcfg_set_key array "package.common.namespaces" "common" "common.stats"
frogcfg_set_key string "package.common.namespaces.common.desc" "Runs a common bullfrog operation"
frogcfg_set_key array "package.common.namespaces.common.operations" "version"
frogcfg_set_key string "package.common.namespaces.common.operations.version.desc" "Displays bullfrog version"
frogcfg_set_key array "package.common.namespaces.common.operations.version.parameters" ""
frogcfg_set_key string "package.common.namespaces.common.stats.desc" "Runs a common bullfrog operation"
frogcfg_set_key array "package.common.namespaces.common.stats.operations" "default"
frogcfg_set_key string "package.common.namespaces.common.stats.operations.default.desc" "General statistics"
frogcfg_set_key array "package.common.namespaces.common.stats.operations.default.parameters" ""
frogcfg_set_key array "package.common.aliases" "cat dog" "mouse rabbit"
frogcfg_set_key array "package.common.zaliases" "crt dog" "rouse rabbit"
