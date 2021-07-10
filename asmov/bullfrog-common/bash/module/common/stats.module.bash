#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

op_common_stats_default () {
    local _result

    frogl_header "common.stats"

    frogl_bullet "/etc/os-release"

    _result="$(cat /etc/os-release | head -2 | sed -re 's/^.*"(.+)".*$/\1/g' | tr '\n' ' ')"

    frogl_print_data "OS" "$_result"

    frogl_spacer
    frogl_bullet "iostat"

    _result=($(echo "$(iostat)" | head -1))

    frogl_print_data "Kernel" "${_result[1]}"
    frogl_print_data "Arch" "${_result[4]:1:-1}"
    frogl_print_data "Hostname" "${_result[2]:1:-1}"

    frogl_spacer
    frogl_bullet "/proc"

    _result="$(cat /proc/cpuinfo | grep '^model name' | head -1 | sed -e 's/^.*: //g')"
    frogl_print_data "CPU" "$_result"

    _result="$(cat /proc/meminfo | grep '^MemTotal' | sed -re 's/^.*:\s*//g' -e 's/ kB//g')"
    _result="$(echo "$_result / 1000000" | bc) gb"
    frogl_print_data "RAM" "$_result"

    frogl_spacer
    frogl_bullet "df"

    mapfile -t _result <<< "$(df -h | grep "\/$" | awk '{ print $2 ; print $4 }')"
    frogl_print_data "Root" "${_result[0]:0:-1} gb (total) / ${_result[1]:0:-1} gb (free)"

    frogl_footer
}