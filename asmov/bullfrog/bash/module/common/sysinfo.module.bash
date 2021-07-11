#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset


op_common_sysinfo_default () {
    local _str
    local -a _arr _xa

    frogl_header "common.sysinfo"

    frogl_bullet "OS"

    _arr="$(head -2 /etc/os-release | sed -re 's/^.*"(.+)".*$/\1/g' | tr '\n' ' ')"

    frogl_print_data "Name" "$_arr"

    _str="$(uname -r)"
    frogl_print_data "Kernel" "${_str/[!0-9.]*}"
    frogl_print_data "Arch" "$(uname -p)"

    frogl_spacer
    frogl_bullet "Hardware"

    _str="$(grep '^model name' /proc/cpuinfo | head -1 | sed -e 's/^.*: //g')"
    frogl_print_data "CPU" "$_str"

    _str="$(grep '^MemTotal' /proc/meminfo | sed -re 's/^.*:\s*//g' -e 's/ kB//g')"
    _str="$(echo "$_str / 1000000" | bc) gb"
    frogl_print_data "RAM" "$_str"

    frogl_spacer
    frogl_bullet "Storage"

    mapfile -t _arr <<< "$(df -h | grep "\/$" | awk '{ print $2 ; print $4 }')"
    frogl_print_data "Root" "${_arr[1]:0:-1} gb (free) / ${_arr[0]:0:-1} gb (total)"

    frogl_spacer
    frogl_bullet "Network"

    frogl_print_data "Hostname" "$(hostname)"

    frogl_print_data "IP" \
        "$(dig +short myip.opendns.com @resolver1.opendns.com)"

    frogl_print_data "Interfaces" ""

    mapfile -t _arr <<< \
        "$(ip address show | grep ' scope global ' | awk '{ sub(/\/.*$/, "", $2) ; print $2 " " $NF }')"

    for _r in "${_arr[@]}"; do
        read -ra _xa <<< "$_r"
        frogl_print_data "   ${_xa[1]}" "${_xa[0]}"
    done

    frogl_spacer
    frogl_bullet "bash"

    frogl_print_data "Version" "${BASH_VERSION/%[!0-9.]*}"
    frogl_print_data "OS Type" "$OSTYPE"
    frogl_print_data "extglob" "$(shopt extglob | awk '{ print $2 }')"

    frogl_spacer
    frogl_bullet "nodejs"

    frogl_print_data "Version" \
        "$(command -v node > /dev/null && { _str="$(node -v)" && echo "${_str[@]:1}"; } || echo "not installed")"
    frogl_print_data "V8 Version" \
        "$(command -v node > /dev/null && { node -p process.versions.v8 | sed -e 's/\.[0-9]*\-.*$//'; } || echo "not installed" )"

    frogl_spacer
    frogl_bullet "python"

    frogl_print_data "Version" \
        "$(command -v python3 > /dev/null && { python3 --version | awk '{ print $2 }'; } || echo "not installed" )"

    frogl_spacer
    frogl_bullet "rust"

    frogl_print_data "Version" \
        "$(command -v rustc > /dev/null && { rustc --version | awk '{ print $2 }'; } || echo "not installed")"

    frogl_spacer
    frogl_bullet "java"

    frogl_print_data "Version" \
        "$(command -v java > /dev/null && { java --version | head -1 | awk '{ print $2 }'; } || echo "not installed")"

    frogl_footer
}