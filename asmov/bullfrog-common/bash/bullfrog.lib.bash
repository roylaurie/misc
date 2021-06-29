#!/bin/bash

# configure bash options:
#  - allexport: treat this script as a library and export all global variables and functions
#  - errexit: fail on uncaught errors
#  - privileged: do not inherit the environment
#  - pipefail: the right-most command in a pipe is its exit code
#  - nounset: throw error on unset variable usage
set -o allexport -o errexit -o privileged -o pipefail -o nounset 

frog_script_dir () {
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
    _jsonPath="$(realpath "$1"/namespace.json)"
    _json="$(cat $_jsonPath | jq -c)" 

    #_ifs=$IFS ; IFS='\r\n'
    _FROG_IMPORTS+=("$_json")
    #IFS=$_ifs
}

##
# Uses the jq tool to query json for data
# @param string json
# @param string query
# @returns string data
##
frog_jq () {
    _json="$1"
    _query="$2"
    _result="$(echo $_json | jq -c $_query)"
    echo $_result
}

$_FROG_CMDLINE_OPTIONS=("help")


frog_parse_cmdline () {
    _cmdline="$@"

    _options=()
    _namespace=""
    _operation=""
    _params=""

    while (("$#")); do
        _token="$1"
        if ((!$_namespace)); then
            if [[ $_token =~ ^--.+ ]]; then  # it's an option

            else
               frogl_error 1 "Invalid parameter token: $_token"
            fi 
            
        fi
    done
    

}

frogl_error () {
    _exitCode="$1"
    _errorMessage="$2"
    1>&2 echo "bullfrog error: (${_exitCode}) $_errMessage"
    exit $_exitCode
}

frogl_bullet () {
        printf "${FROGL_GRN}|=== ${1}%s*|${FROG_NC}" " " $(eval length $1 - 82 - 1) 
}

function frogl_start {
    echo
    echo -e "${GRN}++---------------------------------------------------------------------------++${NC}"
    echo -e "${GRN}+-------------------------- ${1} -------------------------+${NC}"
    echo -e "${GRN}|                                                                             |${NC}"
}

function frogl_header {
        echo
}

function frogl_footer {
        echo
}

function frogl_end {
        echo
}

_FROG_BASEPATH="$(realpath $(frog_script_dir)/../../)"
_FROG_COMMON_PATH="$(realpath $_FROG_BASEPATH/bullfrog-common)/bash/"
_FROG_LOCAL_PATH="$(realpath $_FROG_BASEPATH/bullfrog-local)/bash/"
_FROG_REMOTE_PATH="$(realpath $_FROG_BASEPATH/bullfrog-remote)/bash/"

_FROG_IMPORTS=()

_FROGL_GRN='\033[1;32m'
_FROGL_NC='\033[0m' 

