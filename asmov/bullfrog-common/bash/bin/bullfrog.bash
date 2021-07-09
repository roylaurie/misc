#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

# shellcheck source=../lib/bullfrog.lib.bash
# shellcheck disable=SC2116 # useless echo
source "$( echo "$(
    _script_dir () {
         local _src _dir
         _src="${BASH_SOURCE[0]}"
         while [ -h "$_src" ]; do
              _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
              _src="$( readlink "$_src" )"
              [[ "$_src" != /* ]] && _src="$_dir/$_src"
         done
         _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
         echo "$_dir"
    }

    _script_dir
)" )"/../lib/bullfrog.lib.bash

frog_import_builtin

main () {
    local _result
    _result="$(frog_parse_cmdline "$@")" || frog_error
    local -a _cmdline
    readarray -t _cmdline <<< "$_result"

    # 1: namespace, 2: operation, 3: param names tabarray, 4: param values tabarray
    frog_run_operation "${_cmdline[0]}" "${_cmdline[1]}" "${_cmdline[2]}" "${_cmdline[3]}"
}

main "$@"
