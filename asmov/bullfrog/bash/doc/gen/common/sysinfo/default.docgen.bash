#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset

docgen_common_sysinfo_default () {
    frogdoc_header "common.sysinfo"
    frogdoc_title "OS"
    frogdoc_field "Name" "os.name"
    frogdoc_field "Kernel" "os.kernel"
    frogdoc_field "Arch" "os.arch"
    frogdoc_newline
    frogdoc_title "Hardware"
    frogdoc_field "CPU" "hardware.cpu"
    frogdoc_field "RAM" "hardware.ram"
    frogdoc_newline
    frogdoc_title "Storage"
    frogdoc_field "Root" "%{storage.free}% gb (free) / %{storage.free}% gb (total)"
    frogdoc_newline
    frogdoc_title "Network"
    frogdoc_field "Hostname" "network.hostname"
    frogdoc_field "IP" "network.ip"
    frogdoc_field_title "Interfaces"
    frogdoc_field_kv "network.interfaces.names" "network.interfaces.values"
    frogdoc_newline
    frogdoc_title "bash"
    frogdoc_field "Version" "bash.verison"
    frogdoc_field "OS Type" "bash.ostype"
    frogdoc_field "extglob" "bash.extglob"
    frogdoc_newline
    frogdoc_title "nodejs"
    frogdoc_field "Version" "nodejs.verison"
    frogdoc_field "V8 Version" "node.v8.version"
    frogdoc_newline
    frogdoc_title "python"
    frogdoc_field "Version" "python.version"
    frogdoc_newline
    frogdoc_title "rust"
    frogdoc_field "Version" "rust.version"
    frogdoc_newline
    frogdoc_title "java"
    frogdoc_field "Version" "java.version"
    frogdoc_footer
}