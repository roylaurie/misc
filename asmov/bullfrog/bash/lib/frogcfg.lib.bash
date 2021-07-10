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

frogcfg_has_key () {
  frogcfg_key_index "$1" > /dev/null
}

frogcfg_get_value() {
    local _type _key
    _type="$1"
    _key="$2"

    local _index _offset _valueType _start _size
    _index="$(frogcfg_key_index "$_key")" ||
        frog_error 1 "Cannot find config key" "$_key" "frogcfg_get_value"

    read -r -a _offset <<< "${_FROGCFG_OFFSETS[$_index]}"
    _valueType="${_offset[0]}"
    _start="${_offset[1]}"
    _size="${_offset[2]}"

    [[ "$_type" != "$_valueType" ]] &&
        frog_error 1 "Wrong data type specified for config key/type " "$_key / $_type" "frogcfg_get_value"

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

frogcfg_debug () {
    frog_option_debug || return 0

    for (( _i=0, _n=${#_FROGCFG_KEYS[@]} ; _i < _n ; ++_i )); do
        local _key="${_FROGCFG_KEYS[$_i]}" _valueType
        local -a _offset
        read -ra _offset <<< "${_FROGCFG_OFFSETS[$_i]}"
        _valueType="${_offset[0]}"

        [[ "$_valueType" = "string" ]] &&
            frog_debug "CFG" "$_key" "= $(frogcfg_get_value string "$_key")"
    done

    return 0
}
