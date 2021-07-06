#!/bin/bash
# Bullfrog Bash Toolkit Library
#
# This library is intended for developers that wish to rapidly implement their own command-line toolkits and tools.
#
# Additional libraries included provide utilities for logging, common shell commands,
# and common system administration.
#
# Sourcing this file (bullfrog.lib.bash) and setting the frog_error_trap are the only requisites for standalone use.
#
# All shell access is directed at the facade script (e.g., bullfrog.bash), which in turn 
# runs the correct module script for the namespace and operation specified (e.g., my.foo add, my.bar view).
#
# Namespace configuration is imported at startup and used to determine what operations 
# are available, how they are invoked, and how parameter data should be validated for them.
#
# Usage format is <facade.bash> <-options> <name.spa.ce> <operation> <positional parameters> <--paramaters>
# E.g.,:
#   bullfrog -xf common.test cmdline --param.1 "bool raw" --param.2 "string full.name" --raw true --full.name "earl gray"
#   bullfrog help common.test cmdline
#
# Bullfrog uses JSON along with the jq and ajv commands to pass valid structured data between bash functions and scripts.
#
# Custom namespaces (with modules) may be installed and imported to enhance the functionality of a bullfrog toolkit.
# Each namespace module may have one "default" operation which may be omitted from the command line, without any parameters.

# Configure bash options:
#  - allexport: treat this script as a library and export all global variables and functions
#  - errexit: fail on uncaught errors
#  - privileged: do not inherit the environment
#  - pipefail: the right-most command in a pipe is its exit code
#  - nounset: throw error on unset variable usage
set -o allexport -o errexit -o privileged -o pipefail -o nounset 

NL=$'\n'

declare -A _FROG_PACKAGES
declare -A _FROG_NAMESPACES
_FROG_ERROR_CODE=64

frog_script_dir () {
     local _src _dir
     _src="${BASH_SOURCE[0]}"
     # while _src is a symlink, resolve it
     while [ -h "$_src" ]; do
          _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
          _src="$( readlink "$_src" )"
          # if _src was a relative symlink (no '/' as prefix, resolve it relative to the symlink base directory
          [[ $_src != /* ]] && _src="$_dir/$_src"
     done
     _dir="$( cd -P "$( dirname "$_src" )" && pwd )"
     echo "$_dir"
}

frog_common_path () {
    echo "$_FROG_COMMON_PATH"
}

frog_common_bash_path () {
    echo "$_FROG_COMMON_BASH_PATH"
}

frog_common_bashlib_path () {
    echo "$_FROG_COMMON_BASHLIB_PATH"
}

frog_common_json_path () {
    echo "$_FROG_COMMON_JSON_PATH"
}

frog_common_json_schema_path () {
    echo "$_FROG_COMMON_JSON_SCHEMA_PATH"
}

frog_common_skeleton_path () {
    echo "$_FROG_COMMON_SKELETON_PATH"
}

frog_import_namespace () {
    local _filepath
    _filepath="$1"

    #TODO
    local _packageNamespace="common"

    _FROG_PACKAGES["$_packageNamespace"]="$(realpath "$(dirname "$_filepath")"/..)"
    _FROG_NAMESPACES["common"]="$_packageNamespace"
    _FROG_NAMESPACES["common.stats"]="$_packageNamespace"
}

frog_import_builtin () {
    local _namespaceFilepath

    for _dirname in "${_FROG_COMMON_BUILTIN_PACKAGES[@]}"; do
        _namespaceFilepath="$(realpath "$_FROG_COMMON_DIST_PATH/$_dirname"/json/namespace.json 2>/dev/null)" || continue
        [[ -f "$_namespaceFilepath" ]] &&
            frog_import_namespace "$_namespaceFilepath"
    done
}

frog_inarray () {
    local _search _array
    _search="$1"
    shift && _array=("$@")
    
    for _x in "${_array[@]}"; do
        [ "$_search" == "$_x" ] && return 0
    done

    return 1
}

##
# Parses an entire command entered at the commandline 
#
# Determines and models options that have been set, the namespace and operation specified to run,
# and parameters passed to that operation.
#
# Performs basic data validation based on the operation's imported namespace configuration.
#
# @param $@ _cmdline
# @returns 0: cmdline json config to be executed.
#       1: malformed command, unknown options or parameters, missing options or parameters,
#               unknown namespace / operation, invalid values for options or parameters 
##
frog_parse_cmdline () {
    local _cmdline _forOption="" _namespace="" _operation=""
    IFS=" " read -r -a _cmdline <<< "$@"

    for _token in "${_cmdline[@]}"; do
        if [ -n "$_forOption" ]; then
            continue
        elif [ -n "$_operation" ]; then
            continue
            #if [[ "$_token" =~ ^--.+ ]]; then  # it's an option
            #    _forOption="$_token"
            #else
            #   frog_error 1 "Invalid parameter token" "$_token" "frog_parse_cmdline"
            #fi 
        elif [ -n "$_namespace" ]; then
            _operation="$_token"
        else
            _namespace="$_token"
        fi
    done

    if [ -z "$_operation" ]; then
        _operation="default"
    fi

    echo "$_namespace"
    echo "$_operation"
}

frog_tty () {
    local _a="$*" _t
    _t="$( echo "$(date +%s).$(date +%N)" | bc)"
    echo "[TTY $_t] $_a" > "$(tty)"
}

##
# Searches all imported namespace configs and returns a json config for the specified namespace and operation names.
#
# @param _namespace
# @param _operation
# @returns 0: json result, 1: operation config not found
##
frog_operation_cfg () {
    local _namespace _operation
    _namespace="$1"
    _operation="$2"

    [[ -z "$_namespace" ]] &&
        frog_error 1 "usage: bullfrog [-options] <name.space> <operation> [--parameters]"

    local _packageNamespace
    _packageNamespace="${_FROG_NAMESPACES["$_namespace"]:-}" ||
        frog_error 1 "Invalid namespace $_namespace"

    [[ -z "$_packageNamespace" ]] &&
        frog_error 1 "Invalid namespacse $_namespace"

    local _packagePrefix _opPrefix
    _packagePrefix="package.$_packageNamespace"
    _opPrefix="$_packagePrefix.namespaces.$_namespace.operations.$_operation"

    frogcfg_has_key "$_opPrefix.desc" ||
        frog_error 1 "Invalid operation" "$_namespace::$_operation"

    local -a _paramterNames
    readarray -t _parameterNames <<< "$(frogcfg_get_value array "$_opPrefix.parameters")" ||
        frog_error 1 "Invalid operation" "$_namespace::$_operation"

    local _opScript
    _opScript=""

    local _opFunction
    _opFunction=""

    echo "$_namespace"  # 0
    echo "$_operation"  # 1
    echo "$_opScript"   # 2
    echo "$_opFunction" # 3
}

frog_run_operation () {
    local _cmdCfg _scriptPath _opFunc
    _cmdCfg="$1"
    _scriptPath="$(frog_jq "$_cmdCfg" ".path")" || frog_error $?
    _opFunc="$(frog_jq "$_cmdCfg" ".operationCfg.function")" || frog_error $?
    #_params="$(frog_jq "$_cmdCfg" ".parameters")"

    # shellcheck disable=SC1090
    source "$_scriptPath"
    $_opFunc
}

frog_error () {
    [[ "$1" -eq "$_FROG_ERROR_CODE" ]] && exit "$_FROG_ERROR_CODE"

    local _exitCode _errorMessage _errorDetails="" _subject="" _subjectStr=""
    _exitCode="$1"
    _errorMessage="${2-}"
    [[ -n "${3-}" ]] && _subject="$3" && _subjectStr=" '$(frog_color lightcyan)${_subject}$(frog_color end)'"
    [[ -n "${4-}" ]] && _errorDetails="$4"

    1>&2 echo -e "$(frog_color red)bullfrog error($(frog_color lightgray)${_exitCode}$(frog_color red)):$(frog_color end) ${_errorMessage}${_subjectStr}"
    [ -n "${_errorDetails}" ] && {
        local -a _lines
        mapfile -t _lines <<< "$_errorDetails"
        for _line in "${_lines[@]}"; do
          1>&2 echo -e "$(frog_color red)::$(frog_color end)  $(frog_color lightgray)${_line}$(frog_color end)"
        done
    }

    exit "$_FROG_ERROR_CODE"

}

frog_error_trap () {
    local _exitCode="$?"
    if [ "$_exitCode" -eq "0" ] || [ "$_exitCode" -eq "$_FROG_ERROR_CODE" ]; then
        exit $_exitCode
    fi

    frog_error "$_exitCode" "exited with error code of" "$_exitCode"
}

_FROG_COLOR_NAMES=( end black red green yellow blue magenta cyan lightgray gray lightred lightgreen lightyellow lightblue lightmagenta lightcyan white  ) 
_FROG_COLORS=( 0 30 31 32 33 34 35 36 37 90 91 92 93 94 95 96 97 )
_FROG_STYLE_NAMES=( normal bold faint italic underline )
_FROG_STYLES=( 0 1 2 3 4 )

frog_color () {
    local _colorName _styleName _color="" _style="0"
    _colorName="$1"
    _styleName="${2:-normal}"
    
    for i in "${!_FROG_COLOR_NAMES[@]}"; do
       if [[ "${_FROG_COLOR_NAMES[$i]}" = "$_colorName" ]]; then
            _color="${_FROG_COLORS[$i]}"
            break
       fi
    done 

    [[ -n "$_color" ]] || frog_error 1 "Invalid color" "$_colorName" "frog_color"
    [[ "$_color" = "0" ]] && {
        echo '\e[0m'
        return 0
    }
        
    for i in "${!_FROG_STYLE_NAMES[@]}"; do
       if [[ "${_FROG_STYLE_NAMES[$i]}" = "$_styleName" ]]; then
            _style="${_FROG_STYLES[$i]}"
            break
       fi
    done 

    _style="${_style};"

    echo "\\e[${_style}${_color}m"
}

frog_exec_operation () {
    local _namespace _operation
    _namespace="$1"
    _operation="$2"

    #source file
    #$(${_opFunction} ${_parameters})
}

_FROG_COMMON_PATH="$(realpath "$(frog_script_dir)"/../..)"
_FROG_COMMON_DIST_PATH="$(realpath "$_FROG_COMMON_PATH"/..)"
_FROG_COMMON_BASH_PATH="$(realpath "$_FROG_COMMON_PATH"/bash)"
_FROG_COMMON_BASHCFG_PATH="$(realpath "$_FROG_COMMON_PATH"/bash/cfg)"  # namespace.cfg.min.json lives here
_FROG_COMMON_BASHLIB_PATH="$(realpath "$_FROG_COMMON_PATH"/bash/lib)"
_FROG_COMMON_JSON_PATH="$(realpath "$_FROG_COMMON_PATH"/json)"  # namespace.cfg.min.json lives here
_FROG_COMMON_JSON_SCHEMA_PATH="$(realpath "$_FROG_COMMON_PATH"/json/schema)"
_FROG_COMMON_SKELETON_PATH="$(realpath "$_FROG_COMMON_PATH"/skeleton)"

# shellcheck source=./builtins.lib.bash
source "$_FROG_COMMON_BASHLIB_PATH"/builtins.lib.bash

# shellcheck source=./frogcfg.lib.bash
source "$_FROG_COMMON_BASHLIB_PATH"/frogcfg.lib.bash
# shellcheck source=./frogsys.lib.bash
source "$_FROG_COMMON_BASHLIB_PATH"/frogl.lib.bash
# shellcheck source=./frogsh.lib.bash
source "$_FROG_COMMON_BASHLIB_PATH"/frogsh.lib.bash
# shellcheck source=./frogsys.lib.bash
source "$_FROG_COMMON_BASHLIB_PATH"/frogsys.lib.bash
