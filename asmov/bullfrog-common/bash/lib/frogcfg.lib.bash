#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset

_keys=()
_offsets=()
_values=()

frogcfg_set_key() {
    IFS=$';;'
    _key="$1"
    shift
    _value=("$@")
    #echo ${_value[*]} > /dev/tty
    
    _keys+=("$_key")
    _values+=(${_value[@]})
    _offset="$(( ${#_value[@]} + ${#_values[@]} - 1))"
    _offsets+=("$_offset")

    echo "key $_key"
    echo "siz ${#_value[@]}"
    echo "off ${_offset}"
}

frogcfg_key_index () {
    IFS=$';;'
    _key="$1"

    for (( i=0, n=${#_keys[@]}; i < n; ++i )); do
        [[ "${_keys[$i]}" = "$_key" ]] && echo "$i" && return 0
    done
}

frogcfg_get_values() {
    IFS=$';;'
    _key="$1"
    _i="$(frogcfg_key_index "$_key")" || return 1
    _n="${_offsets[_$i]}"
    echo "i $_i n $_n" > /dev/tty
    echo "bal ${_values[*]:0:2}" > /dev/tty
    echo "${_values[@]:$_i:$_n}" && return 0
}


frogcfg_set_key "package.bullfrog.common.namespaces" "common" "common.stats"
frogcfg_set_key "package.bullfrog.common.namespaces.common.desc" "Runs a common bullfrog operation"
frogcfg_set_key "package.bullfrog.common.namespaces.common.operations" "version"
frogcfg_set_key "package.bullfrog.common.namespaces.common.operations.version.desc" "Displays bullfrog version"
frogcfg_set_key "package.bullfrog.common.namespaces.common.operations.version.parameter" ""
frogcfg_set_key "package.bullfrog.common.namespaces.common.stats.desc" "Runs a common bullfrog operation"
frogcfg_set_key "package.bullfrog.common.namespaces.common.stats.operations" "default"
frogcfg_set_key "package.bullfrog.common.namespaces.common.stats.operations.default.desc" "General statistics"
frogcfg_set_key "package.bullfrog.common.namespaces.common.stats.operations.default.parameter" ""
frogcfg_set_key "package.bullfrog.common.aliases" ""

echo "==="
echo "${_values[*]}"
echo ${_values[0]}
echo ${_values[1]}
echo ${_values[2]}
echo ${_values[3]}

_val=$(frogcfg_get_values "bullfrog-common.common.stats.operations")
echo $_val
echo ${_arr[1]}

