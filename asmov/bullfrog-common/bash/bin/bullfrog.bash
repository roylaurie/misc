#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset

# shellcheck source=./../lib/bullfrog.lib.bash
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")"/..)"/lib/bullfrog.lib.bash

frog_import_builtins

##
# Calls on the bullfrog common library to parse the command line arguments and run a command.
#
# @params ... cmdline ($@)
# @returns 1: error, 0: success
##
main () {
    local _result
    _result="$(frog_parse_cmdline "$@")" || frog_error
    local -a _cmdline
    readarray -t _cmdline <<< "$_result"

    local _namespace _operation _tabarrayParamNames _tabarrayParamValues
    _namespace="${_cmdline[0]}"
    _operation="${_cmdline[1]}"
    _tabarrayParamNames="${_cmdline[2]:-}"
    _tabarrayParamValues="${_cmdline[3]:-}"

    frog_run_operation "$_namespace" "$_operation" "$_tabarrayParamNames" "$_tabarrayParamValues"
}

main "$@"
