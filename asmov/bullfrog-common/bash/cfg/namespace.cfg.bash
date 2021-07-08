#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

frogcfg_set_key array "package.common.namespaces" "common" "common.stats"
frogcfg_set_key string "package.common.namespaces.common.desc" "Runs a common bullfrog operation."
frogcfg_set_key array "package.common.namespaces.common.operations" "version"
frogcfg_set_key string "package.common.namespaces.common.operations.version.desc" "Displays bullfrog version"
frogcfg_set_key array "package.common.namespaces.common.operations.version.parameters" "format"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.desc" "Specifies the format"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.position" "0"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.required" "false"
frogcfg_set_key string "package.common.namespaces.common.stats.desc" "Statistics and metrics"
frogcfg_set_key array "package.common.namespaces.common.stats.operations" "default"
frogcfg_set_key string "package.common.namespaces.common.stats.operations.default.desc" "System statistics"
frogcfg_set_key array "package.common.namespaces.common.stats.operations.default.parameters"

FROG_PACKAGE_NAMESPACE="common"
