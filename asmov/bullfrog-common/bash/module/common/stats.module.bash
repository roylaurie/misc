#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset 

op_common_stats_default () {
    local _result _x
    local -a _results _xa

    frogl_header "common.stats"

    frogl_bullet "/etc/os-release"

    _results="$(cat /etc/os-release | head -2 | sed -re 's/^.*"(.+)".*$/\1/g' | tr '\n' ' ')"

    frogl_print_data "OS" "$_results"

    frogl_spacer
    frogl_bullet "iostat"

    _results=($(echo "$(iostat)" | head -1))

    frogl_print_data "Kernel" "${_results[1]/%[!0-9.]*}"
    frogl_print_data "Arch" "${_results[4]:1:-1}"
    frogl_print_data "Hostname" "${_results[2]:1:-1}"

    frogl_spacer
    frogl_bullet "/proc"

    _result="$(cat /proc/cpuinfo | grep '^model name' | head -1 | sed -e 's/^.*: //g')"
    frogl_print_data "CPU" "$_result"

    _result="$(cat /proc/meminfo | grep '^MemTotal' | sed -re 's/^.*:\s*//g' -e 's/ kB//g')"
    _result="$(echo "$_result / 1000000" | bc) gb"
    frogl_print_data "RAM" "$_result"

    frogl_spacer
    frogl_bullet "df"

    mapfile -t _results <<< "$(df -h | grep "\/$" | awk '{ print $2 ; print $4 }')"
    frogl_print_data "Root" "${_results[1]:0:-1} gb (free) / ${_results[0]:0:-1} gb (total)"

    frogl_spacer
    frogl_bullet "ip"

    mapfile -t _results <<< \
        "$(ip address show | grep ' scope global ' | awk '{ sub(/\/.*$/, "", $2) ; print $2 " " $NF }')"

    for _r in "${_results[@]}"; do
      _xa=($_r)
      frogl_print_data "${_xa[1]}" "${_xa[0]}"
    done

    frogl_print_data "inet" \
        "$(dig +short myip.opendns.com @resolver1.opendns.com)"

    frogl_spacer
    frogl_bullet "bash"
    frogl_print_data "Version" "${BASH_VERSION/%[!0-9.]*}"
    frogl_print_data "OS Type" "$OSTYPE"
    frogl_print_data "extglob" "$(shopt extglob | awk '{ print $2 }')"

    frogl_spacer
    frogl_bullet "nodejs"

    frogl_print_data "Version" \
        "$(_result="$(node -v)" && echo "${_result[@]:1}")"
    frogl_print_data "V8 Version" \
        "$(node -p process.versions.v8 | sed -e 's/\.[0-9]*\-.*$//' )"

    frogl_spacer
    frogl_bullet "python"

    frogl_print_data "Version" \
        "$(python3 --version | awk '{ print $2 }')"

    frogl_spacer
    frogl_bullet "rust"

    frogl_print_data "Version" \
        "$(rustc --version | awk '{ print $2 }')"

    frogl_spacer
    frogl_bullet "java"

    frogl_print_data "Version" \
        "$(java --version | head -1 | awk '{ print $2 }')"




    frogl_footer
}