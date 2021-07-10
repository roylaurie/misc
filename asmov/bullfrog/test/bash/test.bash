#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

log() {
    echo "$1" > "$(tty)"
}

join () {
    local IFS=$1
    echo "${*:2}"
}

echo $HOME