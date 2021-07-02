#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

source $( echo $(
    _script_dir () {
         local _src _dir
         _src="${BASH_SOURCE[0]}"
         while [ -h "$_src" ]; do
              _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
              _src="$( readlink "$_src" )"
              [[ $_src != /* ]] && _src="$_dir/$_src"
         done
         _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
         echo "$_dir"
    }
    
    _script_dir
) )/bullfrog.lib.bash

trap frog_error_trap EXIT

frog_import_builtin

main () {
    local _cmdline
    _cmdline=$(frog_parse_cmdline "$@") || frog_error "$?"

    frog_run_operation "$_cmdline"
}

main $@
