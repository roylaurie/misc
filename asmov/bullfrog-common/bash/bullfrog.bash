#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

_script_dir () {
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

source $(_script_dir)/bullfrog.lib.bash

frog_import_namespace $(frog_common_path)

main() {
    _cmdline="$(frog_parse_cmdline $@)"
    _cmdNamespace=$(frog_jq "$_cmdline" ".namespace")
    _cmdOperation="$(frog_jq "$_cmdline" ".operation")"
    _cmdParameters="$(frog_jq "$_cmdline" ".parameters")"

    case $_cmdNamespace in
    'common')
        case $_cmdOperation in
        'version')
            echo -e "${_FROGL_COLOR_LIGHT_GREEN}bullfrog ${_FROGL_COLOR_LIGHT_GRAY}v0.0.0${_FROGL_ENDCOLOR}"
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

trap frog_error_trap EXIT
main $@
exit 0
