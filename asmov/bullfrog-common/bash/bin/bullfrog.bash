#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

printf "[TTY %i %9i] %s\n" "$(date +%N | bc)" "0" "script start" > /dev/tty

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
) )/../lib/bullfrog.lib.bash

trap frog_error_trap EXIT
frog_tty "load trap"

frog_import_builtin
frog_tty "load import"

main () {
    local _cmdline
    _cmdline=$(frog_parse_cmdline "$@") || frog_error "$?"
frog_tty "load cmd"

    frog_run_operation "$_cmdline"
}

main $@
