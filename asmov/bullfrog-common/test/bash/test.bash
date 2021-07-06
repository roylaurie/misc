#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset

declare -A arr
foo="foobar"
arr["$foo"]="cat"

[[ -z "${arr[$foo]}" ]] && echo "no exist"

echo "${arr[$foo]}"