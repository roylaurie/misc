#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset

_FROGCFG_KEYS=()
_FROGCFG_VALUES=()
_FROGCFG_OFFSETS=()

frogcfg_set_key() {
    local _type _key _value
    _type="$1"
    _key="$2"
    shift 2 && _value=("$@")

    [[ "$_type" != "string" && "$_type" != "array" ]] &&
        frog_error 1 "Invalid data type for config key" "$_key" "$_type"

    local _start _size
    _start="${#_FROGCFG_VALUES[@]}"
    _size="${#_value[@]}"

    [[ "$_size" -gt 1 && "$_type" = "string" ]] &&
        frog_error 1 "Cannot convert string to array for config key" "$_key" "frogcfg_get_value"

    _FROGCFG_KEYS+=("$_key")
    _FROGCFG_VALUES+=("${_value[@]}")
    _FROGCFG_OFFSETS+=("$_type $_start $_size")
}

frogcfg_key_index () {
    local _key
    _key="$1"

    for (( i=0, n="${#_FROGCFG_KEYS[@]}"; i < n; ++i )); do
        [[ "${_FROGCFG_KEYS[$i]}" = "$_key" ]] && echo "$i" && return 0
    done

    return 1
}

logtty () {
  echo "$@" > "$(tty)"
}

frogcfg_get_value() {
    local _type _key
    _type="$1"
    _key="$2"

    local _index _offset _valueType _start _size
    _index="$(frogcfg_key_index "$_key")" || frog_error 1 "Cannot find config key" "$_key"
    read -r -a _offset <<< "${_FROGCFG_OFFSETS[$_index]}"
    _valueType="${_offset[0]}"
    _start="${_offset[1]}"
    _size="${_offset[2]}"

    [[ "$_type" != "$_valueType" ]] &&
        frog_error 1 "Wrong data type specified for config key" "$_key" "$_type"

    if [[ "$_type" = "array" ]]; then
        local -a _result
        _result=("${_FROGCFG_VALUES[@]:$_start:$_size}")

        for _r in "${_result[@]}"; do
            echo "$_r"
        done
    else
        echo "${_FROGCFG_VALUES[$_start]}"
    fi
}

frog_error () {
  echo "$@" > "$(tty)"
  exit 1
}

frogcfg_set_key array "package.bullfrog.common.namespaces" "common" "common.stats"
frogcfg_set_key string "package.bullfrog.common.namespaces.common.desc" "Runs a common bullfrog operation"
frogcfg_set_key array "package.bullfrog.common.namespaces.common.operations" "version"
frogcfg_set_key string "package.bullfrog.common.namespaces.common.operations.version.desc" "Displays bullfrog version"
frogcfg_set_key string "package.bullfrog.common.namespaces.common.stats.desc" "Runs a common bullfrog operation"
frogcfg_set_key array "package.bullfrog.common.namespaces.common.stats.operations" "default"
frogcfg_set_key string "package.bullfrog.common.namespaces.common.stats.operations.default.desc" "General statistics"
frogcfg_set_key array "package.bullfrog.common.namespaces.common.stats.operations.default.parameters" ""
frogcfg_set_key array "package.bullfrog.common.aliases" "cat dog" "mouse rabbit"
frogcfg_set_key array "package.bullfrog.common.zaliases" "crt dog" "rouse rabbit"

echo "+++"

declare -a v
readarray -t v <<< "$(frogcfg_get_value array "package.bullfrog.common.namespaces")"
echo "out ${v[*]}"
echo "out1 ${v[1]}"

readarray -t v <<< "$(frogcfg_get_value array "package.bullfrog.common.zaliases")"
echo "out ${v[*]}"
echo "out ${v[0]}"

x="$(frogcfg_get_value string "package.bullfrog.common.namespaces.common.desc")"
echo "x $x"

x="$(frogcfg_get_value string "package.bullfrog.common.namespaces.common.stats.operations.default.desc")"
echo "x $x"
