#!/bin/bash

# configure bash options:
#  - allexport: treat this script as a library and export all global variables and functions
#  - errexit: fail on uncaught errors
#  - privileged: do not inherit the environment
#  - pipefail: the right-most command in a pipe is its exit code
#  - nounset: throw error on unset variable usage
set -o allexport -o errexit -o privileged -o pipefail -o nounset 

frog_script_dir () {
     local _src _dir
     _src="${BASH_SOURCE[0]}"
     # while _src is a symlink, resolve it
     while [ -h "$_src" ]; do
          _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
          _src="$( readlink "$_src" )"
          # if _src was a relative symlink (no '/' as prefix, resolve it relative to the symlink base directory
          [[ $_src != /* ]] && _src="$_dir/$_src"
     done
     _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
     echo "$_dir"
}

frog_basepath () {
    echo "$_FROG_BASEPATH"
}

frog_common_path () {
    echo "$_FROG_COMMON_PATH"
}

frog_local_path () {
    echo "$_FROG_LOCAL_PATH"
}

frog_remote_path () {
    echo "$_FROG_REMOTE_PATH"
}

frog_import_namespace () {
    local _json _jsonPath
    _jsonPath="$(realpath "$1"/namespace.json)"
    _json="$(cat $_jsonPath | jq -c 2>&1)" || frog_error $? "Unable to parse json file" $_jsonPath "jq> $_json"
    _FROG_IMPORTS+=("$_json")
}

##
# Uses the jq tool to query json for data
# @param string json
# @param string query
# @returns string data
##
frog_jq () {
    local _json _query _result
    _json="$1"
    _query="$2"
    _result="$(echo $_json | jq -rc $_query)"
    echo $_result
}

#$_FROG_CMDLINE_OPTIONS=("help")

frog_parse_cmdline () {
    local _cmdline=($@) _forOption="" _options=() _optionVals=() _namespace="" _operation="" _params=""

    for _token in "${_cmdline[@]}"; do
        if [ -n "$_forOption" ]; then
            continue
        elif [ -n "$_operation" ]; then
            continue
            #if [[ "$_token" =~ ^--.+ ]]; then  # it's an option
            #    _forOption="$_token"
            #else
            #   frog_error 1 "Invalid parameter token" "$_token" "frog_parse_cmdline"
            #fi 
        elif [ -n "$_namespace" ]; then
            _operation="$_token"
        else
            _namespace="$_token"
        fi
    done

    if [ -z "$_operation" ]; then
        _operation="default"
    fi

    echo "{ \"namespace\": \"$_namespace\", \"operation\": \"$_operation\", \"parameters\": { \"toggle\": \"1\" } }"
}

frog_error () {
    local _exitCode _errorMessage _subject="" _errorDetails="" _subjectStr=""
    _exitCode="$1"
    _errorMessage="$2"
    [ -n "${3-}" ] && _subject="$3" && _subjectStr=" '${_FROGL_COLOR_LIGHT_CYAN}${_subject}${_FROGL_ENDCOLOR}'"
    [ -n "${4-}" ] && _errorDetails="$4"

    $(1>&2 echo -e "${_FROGL_COLOR_RED}bullfrog error(${_FROGL_COLOR_LIGHT_GRAY}${_exitCode}${_FROGL_COLOR_RED}):${_FROGL_ENDCOLOR} ${_errorMessage}${_subjectStr}")
    [ -n "$_errorDetails" ] && $(1>&2 echo -e "${_FROGL_COLOR_RED}::${_FROGL_ENDCOLOR}    ${_FROGL_COLOR_LIGHT_GRAY}${_errorDetails}${_FROGL_ENDCOLOR}")
    exit $_FROG_ERROR_CODE 
}

frog_error_trap () {
    local _exitCode="$?"
    if [ "$_exitCode" -eq "0" ] || [ "$_exitCode" -eq "$_FROG_ERROR_CODE" ]; then
        return $_exitCode
    fi

    frog_error $_exitCode "exited with error code of" $_exitCode
}

_FROG_ERROR_CODE=64

_FROG_BASEPATH="$(realpath $(frog_script_dir)/../..)"

_FROG_COMMON_PATH="$(realpath $_FROG_BASEPATH/bullfrog-common)/bash"
_FROG_LOCAL_PATH="$(realpath $_FROG_BASEPATH/bullfrog-local)/bash"
_FROG_REMOTE_PATH="$(realpath $_FROG_BASEPATH/bullfrog-remote)/bash"

_FROG_IMPORTS=()

_FROGL_COLOR_BLACK='\e[30m'
_FROGL_COLOR_RED='\e[31m'
_FROGL_COLOR_GREEN='\e[32m'
_FROGL_COLOR_YELLOW='\e[33m'
_FROGL_COLOR_BLUE='\e[34m'
_FROGL_COLOR_MAGENTA='\e[35m'
_FROGL_COLOR_CYAN='\e[36m'
_FROGL_COLOR_LIGHT_GRAY='\e[37m'
_FROGL_COLOR_GRAY='\e[90m'
_FROGL_COLOR_LIGHT_RED='\e[91m'
_FROGL_COLOR_LIGHT_GREEN='\e[92m'
_FROGL_COLOR_LIGHT_YELLOW='\e[93m'
_FROGL_COLOR_LIGHT_BLUE='\e[94m'
_FROGL_COLOR_LIGHT_MAGENTA='\e[95m'
_FROGL_COLOR_LIGHT_CYAN='\e[96m'
_FROGL_COLOR_WHITE='\e[97m'

_FROGL_ENDCOLOR='\e[0m' 

source $_FROG_COMMON_PATH/frogl.lib.bash
source $_FROG_COMMON_PATH/frogsh.lib.bash
source $_FROG_COMMON_PATH/frogsys.lib.bash
