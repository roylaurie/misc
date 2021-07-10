#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset


op_common_remote_default () {
    echo "$(frog_option_remote)"
}

op_common_remote_install () {
    local _host
    _host="$(frog_option_remote)"
    _pkgFilename="bullfrog-common-2021.1.0.amd64.deb"
    _pkgFilepath="$(realpath "$(frog_common_path)/dist/$_pkgFilename")" ||
        frog_error 1 "Debian package file does not exist"

    [[ "$_host" = "localhost" ]] && frog_error 1 "-r[emote host] not set" "" "op_common_remote_install"

    ssh "$_host" 'mkdir -p ~/tmp'
    scp "$_pkgFilepath" "${_host}:~/tmp" 1> /dev/null
    ssh "$_host" "sudo apt install sysinstall ; sudo dpkg -i ~/tmp/$_pkgFilename"
}