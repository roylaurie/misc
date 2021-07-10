#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

op_common_version () {
    local -a _paramNames _paramValues
    IFS=$'\t' read -ra _paramNames <<< "${1:-}"
    IFS=$'\t' read -ra _paramValues <<< "${2:-}"


    #TODO version extraction
    echo -e "$(frog_color lightgreen)bullfrog $(frog_color lightgray)v$(frog_version)$(frog_color end)"
}