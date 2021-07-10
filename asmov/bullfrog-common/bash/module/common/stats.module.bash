#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

op_common_stats_default () {
    frogl_header "common.stats"

    frogl_bullet "os-release"

    local _dist
    _dist="$(cat /etc/os-release | head -2 | sed -re 's/^.*"(.+)".*$/\1/g' | tr '\n' ' ')"

    frogl_print_data "OS" "$_dist"

    frogl_spacer
    frogl_bullet "iostat"

    local _iostat
    _iostat=($(echo "$(iostat)" | head -1))

    frogl_print_data "Kernel" "${_iostat[1]}"
    frogl_print_data "Arch" "${_iostat[4]:1:-1}"
    frogl_print_data "Hostname" "${_iostat[2]:1:-1}"

    frogl_footer
}