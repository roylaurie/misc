#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

op_common_version () {
    local -a _paramNames _paramValues
    IFS=$'\t' read -ra _paramNames <<< "${1:-}"
    IFS=$'\t' read -ra _paramValues <<< "${2:-}"

    echo -e "$(frog_color lightgreen)bullfrog $(frog_color lightgray)v0.0.0$(frog_color end)"
}