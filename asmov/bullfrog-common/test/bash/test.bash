#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

log() {
    echo "$1" > "$(tty)"
}

join () {
    local IFS=$1
    echo "${*:2}"
}

send () {
    declare -a a b
    a=("foo" "bar" "tar")
    b=("cat dog" "in out" "water wind ice")

    for i in "${a[@]}"; do
        log "a $i"
    done

    for i in "${b[@]}"; do
        log "b $i"
    done

    echo "param one"
    echo "param two"
    join $'\t' "${a[@]}"
    join $'\t' "${b[@]}"
}

recv="$(send)"
log "RECV $recv"

declare -a a a0 a1
mapfile -t a <<< "$recv"
p1="${a[0]}"
p2="${a[1]}"

log "p1 $p1 p2 $p2"

#IFS=$'\t' read -r -a a0 <<< "${a[2]}"
a0="$(split $'\t' "${a[2]}")"
IFS=$'\t' read -r -a a1 <<< "${a[3]}"

for i in "${a[@]}"; do
    log "A $i"
done

for i in "${a0[@]}"; do
    log "A0 $i"
done

for i in "${a1[@]}"; do
    log "A1 $i"
done