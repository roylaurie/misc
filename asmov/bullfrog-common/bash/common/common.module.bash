#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

op_common_version () {
    echo -e "$(frog_color lightgreen)bullfrog $(frog_color lightgray)v0.0.0$(frog_color end)"
}
