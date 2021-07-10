#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

frogcfg_set_key array "package.common.namespaces" "common" "common.sysinfo"
frogcfg_set_key string "package.common.namespaces.common.desc" "Runs a common bullfrog operation."
frogcfg_set_key array "package.common.namespaces.common.operations" "version"
frogcfg_set_key string "package.common.namespaces.common.operations.version.desc" "Displays bullfrog version"
frogcfg_set_key array "package.common.namespaces.common.operations.version.parameters" "format" "service"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.desc" "Specifies the format"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.required" "false"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.position" "0"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.parameters.service.desc" "Turns on or off the version service"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.parameters.service.required" "false"
frogcfg_set_key string "package.common.namespaces.common.operations.version.parameters.format.parameters.service.default" "off"
frogcfg_set_key array "package.common.namespaces.common.operations.version.parameters.format.parameters.service.enum" "off" "on"
frogcfg_set_key string "package.common.namespaces.common.sysinfo.desc" "Provides system information tools"
frogcfg_set_key array "package.common.namespaces.common.sysinfo.operations" "default"
frogcfg_set_key string "package.common.namespaces.common.sysinfo.operations.default.desc" "Displays a general profile of the system"
frogcfg_set_key array "package.common.namespaces.common.sysinfo.operations.default.parameters"

FROG_PACKAGE_NAMESPACE="common"
