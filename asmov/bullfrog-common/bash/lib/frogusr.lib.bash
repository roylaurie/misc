#!/bin/bash
set -o errexit -o pipefail -o privileged -o nounset

frogusr_home () {
    realpath "$HOME"
}

_frogusr_config_dir () {
    local _app _config
    _app="$(frog_option_app)"
    _config="$(frog_option_config)"

    echo "$HOME/.config/bullfrog/$_app/$_config"
}

_frogusr_data_dir () {
    local _app _config
    _app="$(frog_option_app)"
    _config="$(frog_option_config)"

    echo "$HOME/.data/bullfrog/$_app/$_config"
}

frogusr_config_path () {
    [[ -z "$_FROGUSR_CONFIG_PATH" ]] && frog_error 1 "Accessing frogusr_path before frogusr_init" "frogusr_path"
    echo "$_FROGUSR_CONFIG_PATH"
}

frogusr_data_path () {
    [[ -z "$_FROGUSR_DATA_PATH" ]] && frog_error 1 "Accessing frogusr_data_path before frogusr_init" "frogusr_data_path"
    echo "$_FROGUSR_DATA_PATH"
}

frogusr_init () {
    local _app _config _configdir _datadir
    _app="$(frog_option_app)"
    _config="$(frog_option_config)"
    _configdir="$(_frogusr_config_dir)"
    _datadir="$(_frogusr_data_dir)"

    [[ -d "$_configdir" ]] || mkdir -p "$_configdir"
    [[ -d "$_datadir" ]] || mkdir -p "$_datadir"

    _FROGUSR_CONFIG_PATH="$(realpath "$_configdir")"
    _FROGUSR_DATA_PATH="$(realpath "$_datadir")"
}

_FROGUSR_CONFIG_PATH=""
_FROGUSR_DATA_PATH=""
