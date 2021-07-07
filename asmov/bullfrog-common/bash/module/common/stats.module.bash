#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

op_common_stats_default () {
    # shellcheck disable=SC2005
    echo "$(iostat | head -4 | sed '/^[[:space:]]*$/d')"
    cat /etc/os-release | head -2
}