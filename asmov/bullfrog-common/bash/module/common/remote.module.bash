#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset


op_common_remote_default () {
    echo "$(frog_option_remote)"
}

op_common_remote_install () {
    local _host
    _host="$(frog_option_remote)"

    [[ "$_host" = "localhost" ]] && frog_error 1 "Not -r[emote host] has been specified" "" "op_common_remote_install"

}