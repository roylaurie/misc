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

frog_import_namespace $(frog_common_path)

main () {
    _cmdline="$(frog_parse_cmdline $@)"
    _cmdNamespace=$(frog_jq "$_cmdline" ".namespace")
    _cmdOperation="$(frog_jq "$_cmdline" ".operation")"
    _cmdParameters="$(frog_jq "$_cmdline" ".parameters")"

    case $_cmdNamespace in
    'common')
        case $_cmdOperation in
        'version')
                echo -e "$(frog_color lightgreen)bullfrog $(frog_color lightgray)v0.0.0$(frog_color end)"
            ;;
        *)
            frog_error 1 "Unknown operation" "$_cmdNamespace::$_cmdOperation"
            ;;
        esac
        ;;
    *)
        frog_error 1 "Unknown namespace" "$_cmdNamespace"
        ;;
    esac

    exit 0
}

main $@
exit 0
