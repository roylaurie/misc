#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset

docgen_common_sysinfo_default () {
    frogdoc_header "common.sysinfo"
    frogdoc_bullet "OS"
    frogdoc_print_data "Name" "os.name"
    frogdoc_print_data "Kernel" "os.kernel"
    frogdoc_print_data "Arch" "os.arch"
    frogdoc_spacer
    frogdoc_bullet "Hardware"
    frogdoc_print_data "CPU" "hardware.cpu"
    frogdoc_print_data "RAM" "hardware.ram"
    frogdoc_spacer
    frogdoc_bullet "Storage"
    frogdoc_print_data "Root" "%{storage.free}% gb (free) / %{storage.free}% gb (total)"
    frogdoc_spacer
    frogdoc_bullet "Network"
    frogdoc_print_data "Hostname" "network.hostname"
    frogdoc_print_data "IP" "network.ip"
    frogdoc_print_data "Interfaces" ""
    frogdoc_print_data_array "network.interfaces"
    frogdoc_spacer
    frogdoc_bullet "bash"
    frogdoc_print_data "Version" "bash.verison"
    frogdoc_print_data "OS Type" "bash.ostype"
    frogdoc_print_data "extglob" "bash.extglob"
    frogdoc_spacer
    frogdoc_bullet "nodejs"
    frogdoc_print_data "Version" "nodejs.verison"
    frogdoc_print_data "V8 Version" "node.v8.version"
    frogdoc_spacer
    frogdoc_bullet "python"
    frogdoc_print_data "Version" "python.version"
    frogdoc_spacer
    frogdoc_bullet "rust"
    frogdoc_print_data "Version" "rust.version"
    frogdoc_spacer
    frogdoc_bullet "java"
    frogdoc_print_data "Version" "java.version"
    frogdoc_footer
}