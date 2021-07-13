#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

log() {
    echo "$1" > "$(tty)"
}

join () {
    local IFS=$1
    echo "${*:2}"
}

f () {
    local origin='this is a value'
    j origin

    local -ra origins=('this' 'is a' 'value')
    k origins

    echo "newref $origin"
}

j () {
    local -n reference
    reference="$1"
    echo "VALUE $reference"
    reference="f"
}

k () {
    local -n reference=$1
    echo "VALUES ${reference[*]}"
    echo "VALUES ${reference[1]}"
}

f