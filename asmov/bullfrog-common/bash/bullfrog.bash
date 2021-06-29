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
    _scriptNamespace="common.bullfrog"
    _params="$(frog_parse_cmdline $@)"
    _cmdNamespace="$(frog_jq $_params ".namespace")"
    _cmdOperation="$(echo $_params | jq -c ".operation")"
    _cmdArguments="$(echo $_params | jq -c ".arguments")"

    _cmd="$(frog_mkcmd $_cmdNamespace $_cmdOperation $_cmdArguments)"
    echo $_cmd
    #exec $_cmd
}

$(main $@)
exit 0
