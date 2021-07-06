#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

NC=$'\n'
str="alpha${NC}bravo${NC}charlie"
echo "${str}"

declare -a arr
mapfile -t arr <<< "$str"
echo "${#arr[@]}"
