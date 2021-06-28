#!/bin/bash

# configure bash options:
#  - allexport: treat this script as a library and export all global variables and functions
#  - errexit: fail on uncaught errors
#  - privileged: do not inherit the environment
#  - pipefail: the right-most command in a pipe is its exit code
#  - nounset: throw error on unset variable usage
set -o allexport -o errexit -o privileged -o pipefail -o nounset 

frog_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"
     # While $SOURCE is a symlink, resolve it
     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          # If $SOURCE was a relative symlink (so no "/" as prefix, need to resolve it relative to the symlink base directory
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
     echo "$DIR"
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
    _jsonPath="$(realpath $1/namespace.json)"
    _json="$(cat $_jsonPath | jq -c)" 

    #_ifs=$IFS ; IFS='\r\n'
    _FROG_IMPORTS+=("$_json")
    #IFS=$_ifs
}

frogp_bullet () {
        printf "${FROGL_GRN}|=== ${1}%s*|${FROG_NC}" " " $(eval length $1 - 82 - 1) 
}

function frogp_start {
    echo
    echo -e "${GRN}++---------------------------------------------------------------------------++${NC}"
    echo -e "${GRN}+-------------------------- ${1} -------------------------+${NC}"
    echo -e "${GRN}|                                                                             |${NC}"
}

function frogp_header {
        echo
}

function frogp_footer {
        echo
}

function frogp_end {
        echo
}

_FROG_BASEPATH="$(realpath $(frog_script_dir)/../../)"
_FROG_COMMON_PATH="$(realpath $_FROG_BASEPATH/bullfrog-common)/bash/"
_FROG_LOCAL_PATH="$(realpath $_FROG_BASEPATH/bullfrog-local)/bash/"
_FROG_REMOTE_PATH="$(realpath $_FROG_BASEPATH/bullfrog-remote)/bash/"

_FROG_IMPORTS=()

_FROGL_GRN='\033[1;32m'
_FROGL_NC='\033[0m' 

