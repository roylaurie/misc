#!/bin/bash

# configure bash options:
#  - allexport: treat this script as a library and export all global variables and functions
#  - errexit: fail on uncaught errors
#  - privileged: do not inherit the environment
#  - pipefail: the right-most command in a pipe is its exit code
#  - nounset: throw error on unset variable usage
set -o allexport -o errexit -o privileged -o pipefail -o nounset 

frog_script_dir () {
     local _src="${BASH_SOURCE[0]}"
     # while _src is a symlink, resolve it
     while [ -h "$_src" ]; do
          local _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
          local _src="$( readlink "$_src" )"
          # if _src was a relative symlink (no '/' as prefix, resolve it relative to the symlink base directory
          [[ $_src != /* ]] && _src="$_dir/$_src"
     done
     local _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
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
    local _jsonPath="$(realpath "$1"/namespace.json)"
    #local _json="$(cat $_jsonPath | jq -c)" 
    local _json=$(cat $_jsonPath | jq -c) 
    echo $?

    _FROG_IMPORTS+=("$_json")
}

##
# Uses the jq tool to query json for data
# @param string json
# @param string query
# @returns string data
##
frog_jq () {
    local _json="$1"
    local _query="$2"
    local _result="$(echo $_json | jq -c $_query)"
    echo $_result
}

#$_FROG_CMDLINE_OPTIONS=("help")


frog_parse_cmdline () {
    local _cmdline="$@"

    local _options=()
    local _namespace=""
    local _operation=""
    local _params=""

    while (("$#")); do
        local _token="$1"
        if ((!$_namespace)); then
            if [[ $_token =~ ^--.+ ]]; then  # it's an option
                echo "token!"
            else
               frogl_error 1 "Invalid parameter token: $_token"
            fi 
            
        fi
    done
    

}

frog_error () {
    _exitCode="$1"
    _errorMessage="$2"
    `1>&2 echo "bullfrog error: (${_exitCode}) $_errMessage"`
    exit $_exitCode
}

_FROG_BASEPATH="$(realpath $(frog_script_dir)/../..)"

_FROG_COMMON_PATH="$(realpath $_FROG_BASEPATH/bullfrog-common)/bash"
_FROG_LOCAL_PATH="$(realpath $_FROG_BASEPATH/bullfrog-local)/bash"
_FROG_REMOTE_PATH="$(realpath $_FROG_BASEPATH/bullfrog-remote)/bash"

_FROG_IMPORTS=()

source $_FROG_COMMON_PATH/frogl.lib.bash
source $_FROG_COMMON_PATH/frogsh.lib.bash
source $_FROG_COMMON_PATH/frogsys.lib.bash
