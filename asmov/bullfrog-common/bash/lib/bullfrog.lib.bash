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

# shellcheck disable=SC2034  # unused
NL=$'\n'

##
# Retrieves the real absolute directory path for the calling script.
#
# @returns 1: error, 0: success { string dirpath }
##
frog_script_dir () {
    realpath "$(dirname "${BASH_SOURCE[0]}")"
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

# Used by each package's namespace.cfg.bash file to specify the package's root namespace is.
FROG_PACKAGE_NAMESPACE=""

##
# Imports a package by sourcing its namespace.cfg.bash, which should make calls to frogcfg to configure itself.
# The config script should re-define FROG_PACKAGE_NAMESPACE as well, for processing.
#
# @param string filepath The path of the namespace.cfg.bash file for this package.
# @returns 1: error, 0: success
##
frog_import_package () {
    local _filepath
    _filepath="$1"

    # shellcheck disable=SC1090
    source "$_filepath"
    local _packageNamespace="${FROG_PACKAGE_NAMESPACE:-}"

    local _result
    _result="$(frogcfg_get_value array "package.$_packageNamespace.namespaces")" || frog_error
    local -a _namespaces
    readarray -t _namespaces <<< "$_result"

    _FROG_PACKAGES["$_packageNamespace"]="$(realpath "$(dirname "$_filepath")"/../..)"

    for _namespace in "${_namespaces[@]}"; do
        _FROG_NAMESPACES["$_namespace"]="$_packageNamespace"
    done
}

##
# Finds any official bullfrog- packages installed in the same prefix and imports them, if possible.
#
# @returns 1: error, 0: success
##
frog_import_builtins () {
    local _namespaceFilepath

    for _dirname in "${_FROG_COMMON_BUILTIN_PACKAGES[@]}"; do
        _namespaceFilepath="$(realpath "$_FROG_COMMON_DIST_PATH/$_dirname"/bash/cfg/namespace.cfg.bash 2>/dev/null)" || continue
        [[ -f "$_namespaceFilepath" ]] &&
            frog_import_package "$_namespaceFilepath"
    done
}

##
# Searches for an element within an array.
#
# @param string search
# @param array array
# @returns 1: not found, 0: found
##
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
# @param ... cmdline The arguments as passed to the command-line ($@)
# @returns 1: error, 0: success {
#    0: string namespace
#    1: string operation
#    2: tabarray parameter names
#    3: tabarray parameter values }
##
frog_parse_cmdline () {
    local -A _options
    _options[a]="common" # application package namespace
    _options[c]="default" # config profile name
    _options[f]="false" # force
    _options[x]="false" # debug
    _options[X]="false" # bash debug

    local _o
    while getopts a:c:fxX _o 2> /dev/null; do
        case "$_o" in
            a)  _options[a]="$OPTARG" ;;
            c)  _options[c]="$OPTARG" ;;
            f)  _options[f]="true" ;;
            x)  _options[x]="true" ;;
            X)  _options[X]="true" ;;
            *)  local _last=$(( OPTIND - 1 ))
                frog_error 1 "Illegal option" "${!_last}" "frog_parse_cmdline" ;;
        esac
    done

    shift $(( "$OPTIND" - 1 ))

    local _namespace
    _namespace="${1:-}"
    [[ -z "$_namespace" ]] &&
        frog_error 1 "usage: bullfrog [-options] <name.space> <operation> [--parameters]"
    [[ "$_namespace" =~ $_FROG_NAMESPACE_PATTERN ]] ||
        frog_error 1 "Improper formatting of namespace" "$_namespace" "frog_parse_cmdline"

    shift 1

    local _operation
    _operation="${1:-}"
    if [[ -z "$_operation" ]]; then
        _operation="default"
    elif [[ "$_operation" = "default" ]]; then
        shift 1
    elif [[ "$_operation" =~ $_FROG_NAMESPACE_PATTERN ]]; then
        shift 1
    else
        frog_error "1" "Improperly formated operation" "$_operation" "frog_parse_cmdline"
    fi

    [[ "$_operation" = "default" && "$#" -gt 1 ]] &&
        frog_error 1 "Parameters are not allowed with default operations" "frog_parse_cmdline"

    local -a _parameterNames=() _parameterValues=()

    for (( i=1, n="$#" ; i <= n ; ++i )); do
        local _token _iskey
        _token="${!i}"
        _iskey="$(( i % 2))"

        if [[ "$_iskey" -eq 1 ]]; then
            [[ "$_token" =~ $_FROG_PARAMETER_PATTERN ]] ||
                frog_error "1" "Improperly formatted parameter name" "$_token" "frog_parse_cmdline"

            _parameterNames+=("$_token")
        else
            _parameterValues+=("$_token")
        fi
    done

    [[ "${#_parameterNames[@]}" -ne "${#_parameterValues[@]}" ]] &&
        frog_error 1 "Missing value for parameter" "" "frog_parse_cmdline"

    echo "$_namespace"
    echo "$_operation"
    frog_join "${_parameterNames[@]}"
    frog_join "${_parameterValues[@]}"
    frog_join "${!_options[@]}" # keys
    frog_join "${_options[@]}" # values
}

frog_process_options () {
    local _optionNames _optionValues
    IFS=$'\t' read -ra _optionNames <<< "$1"
    IFS=$'\t' read -ra _optionValues <<< "$2"

    frogcfg_set_key array "options" "a" "c" "f" "x"

    for (( i=0, n="${#_optionNames[@]}"; i < n; ++i )); do
        local _opt="${_optionNames[$i]}"
        local _val="${_optionValues[$i]}"
        case "$_opt" in
            a)  frogcfg_set_key string "options.app" "$_val"
                _FROG_OPTION_APP="$_val" ;;
            c)  frogcfg_set_key string "options.config" "$_val"
                _FROG_OPTION_CONFIG="$_val" ;;
            f)  frogcfg_set_key string "options.force" "$_val"
                [[ "$_val" = "true" ]] && _FROG_OPTION_FORCE=1 ;;
            x)  frogcfg_set_key string "options.debug" "$_val"
                [[ "$_val" = "true" ]] && _FROG_OPTION_DEBUG=1 ;;
            X)  frogcfg_set_key string "options.bash.debug" "$_val"
                [[ "$_val" = "true" ]] && _FROG_OPTION_BASH_DEBUG=1 ;;
            *)  frog_error 1 "Unknown option" "$_opt" "frog_process_options" ;;
        esac
    done
}

##
# Joins the specified array's elements together by the tab IFS character.
# We call the product output a "tab-array". They are used to pass arrays between functions.
# To split back into a normal array, use: IFS=$'\t' read -ar <<< "$tabarray"
#
# @param array data
# @returns 1: error, 0: success { tabarray }
##
frog_join () {
    local IFS=$'\t'
    echo "${*:1}"
}

##
# Outputs a debugging message to the tty device (typically /dev/tty)
#
# @param string subject
# @param ... values to be output
# @returns 1: error, 0: success
##
frog_debug () {
    [[ $_FROG_OPTION_DEBUG -eq 0 ]] && return 0

    local _time _tty _subject _params
    _time="$( echo "$(date +%s).$(date +%N)" | bc)"
    _tty="$(tty)"
    _subject="$1"
    shift && _params="$*"

    echo -en "\\e[37m[DEBUG $_time]  \\e[36m" > "$_tty"
    echo -n "$_params" > "$_tty"
    echo -e "\\e[0m" > "$_tty"
}


##
# Retrieves pertinent configuration data for making calls to the namespace/operation specified.
#
# @param string namespace
# @param string? operation
# @returns 1: error, 0: success {
#    0: string namespace
#    1: string operation
#    2: string opScript The filepath to the module script for this operation
#    3: string opFunction The function name to call withing the module script }
##
frog_operation_cfg () {
    local _namespace _operation
    _namespace="$1"
    _operation="$2"

    [[ -z "$_namespace" ]] &&
        frog_error 1 "usage: bullfrog [-options] <name.space> <operation> [--parameters]"

    local _packageNamespace
    _packageNamespace="${_FROG_NAMESPACES["$_namespace"]:-}"
    [[ -z "$_packageNamespace" ]] &&
        frog_error 1 "Unknown namespace" "$_namespace" "frog_operation_cfg"

    local _packagePrefix _opPrefix
    _packagePrefix="package.$_packageNamespace"
    _opPrefix="$_packagePrefix.namespaces.$_namespace.operations.$_operation"

    # test to see if the operation exists
    frogcfg_has_key "$_opPrefix.desc" ||
        frog_error 1 "Invalid operation" "$_namespace::$_operation"

    local _result
    _result="$(frogcfg_get_value array "$_opPrefix.parameters")" || frog_error
    local -a _paramterNames
    readarray -t _parameterNames <<< "$_result"

    local _packagePath
    _packagePath="${_FROG_PACKAGES["$_packageNamespace"]}"

    local _opScript
    _opScript="$(frog_module_path "$_packagePath" "$_namespace")" || frog_error

    local _opFunction
    _opFunction="$(frog_module_function "$_namespace" "$_operation")" || frog_error

    echo "$_namespace"  # 0
    echo "$_operation"  # 1
    echo "$_opScript"   # 2
    echo "$_opFunction" # 3
}

##
# Retrieves the .module.bash filepath for the given package path and namespace
#
# @param string packagePath
# @param string namespace
# @returns 1: error, 0: success { string filepath }
frog_module_path () {
    local _packagePath _namespace
    _packagePath="$1"
    _namespace="$2"

    local _namepath _filepath
    _namepath="${_namespace//\./\/}.module.bash"
    _filepath="$_packagePath/bash/module/$_namepath"

    [[ -f "$_filepath" ]] ||
        frog_error 1 "Module script does not exist" "$_filepath" "frog_module_path"

    echo "$_filepath"
}

##
# Retrieves the .module.bash function name for the given namespace and operation
#
# @param string namespace
# @param string operation
# @returns 1: error, 0: success { string functionName }
frog_module_function() {
    local _namespace _operation
    _namespace="$1"
    _operation="$2"

    echo "op_${_namespace//\./_}_${_operation//\./_}"
}

##
# Sources a module and runs an operation call, passing it parameters that have been parsed.
#
# @param string namespace
# @param string operation
# @param tabarray paramNames
# @param tabarray paramValues
# @returns 1: error, 0: success
##
frog_run_operation () {
    local _namespace _operation _paramNames _paramValues
    _namespace="$1"
    _operation="$2"
    _paramNames="$3"
    _paramValues="$4"

    local -a _result _opCfg
    _result="$(frog_operation_cfg "$_namespace" "$_operation")"
    readarray -t _opCfg <<< "$_result"

    local _opScript _opFunction
    _opScript="${_opCfg[2]}"
    _opFunction="${_opCfg[3]}"

    # shellcheck disable=SC1090
    source "$_opScript"
    frog_option_bash_debug && set -x
    $_opFunction "$_paramNames" "$_paramValues"
}

frog_error () {
    [[ -z "${1:-}" ]] &&
        exit "$_FROG_ERROR_CODE"

    # only frog_error() should throw its own error code, don't report twice
    [[ "$1" -eq "$_FROG_ERROR_CODE" ]] &&
        exit "$_FROG_ERROR_CODE"

    local _exitCode _errorMessage _subject _errorDetails
    _exitCode="$1"
    _errorMessage="${2-}"
    _subject="${3-}"
    _errorDetails="${4-}"

    _frog_print_error "$_exitCode" "$_errorMessage" "$_subject" "$_errorDetails"

    exit "$_FROG_ERROR_CODE"
}

_frog_print_error () {
    local _exitCode _errorMessage _subject _errorDetails
    _exitCode="$1"
    _errorMessage="${2-}"
    _subject="${3-}"
    _errorDetails="${4-}"

    local _subjectStr=""
    [[ -n "$_subject" ]] &&
        _subjectStr=" '$(frog_color lightcyan)${_subject}$(frog_color end)'"

    echo -e "$(frog_color red)bullfrog error($(frog_color lightgray)${_exitCode}$(frog_color red)):$(frog_color end) ${_errorMessage}${_subjectStr}" >&2
    [ -n "${_errorDetails}" ] && {
        local -a _lines
        mapfile -t _lines <<< "$_errorDetails"
        for _line in "${_lines[@]}"; do
          echo -e "$(frog_color red)::$(frog_color end)  $(frog_color lightgray)${_line}$(frog_color end)" >&2
        done
    }
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

frog_option_app() {
    echo "$_FROG_OPTION_APP"
}

frog_option_config() {
    echo "$_FROG_OPTION_CONFIG"
}

##
# Determines whethere the -f[orce] option is enabled or not.
#
# @returns 1: force disabled, 0: force enabled
##
frog_option_force () {
    [[ $_FROG_OPTION_FORCE -eq 1 ]] && return 0
    return 1
}

frog_option_debug () {
    [[ $_FROG_OPTION_DEBUG -eq 1 ]] && return 0
    return 1
}

frog_option_bash_debug () {
    [[ $_FROG_OPTION_BASH_DEBUG -eq 1 ]] && return 0
    return 1
}

_FROG_ERROR_CODE=64

_FROG_COMMON_PATH="$(realpath "$(frog_script_dir)"/../..)"  # the base dirtory of the package
_FROG_COMMON_DIST_PATH="$(realpath "$_FROG_COMMON_PATH"/..)"  # where other built-in packages may be installed
_FROG_COMMON_BASH_PATH="$(realpath "$_FROG_COMMON_PATH"/bash)"  # bullfrog.bash in bash/bin
_FROG_COMMON_BASHCFG_PATH="$(realpath "$_FROG_COMMON_PATH"/bash/cfg)"  # namespace.cfg.bash lives here
_FROG_COMMON_BASHLIB_PATH="$(realpath "$_FROG_COMMON_PATH"/bash/lib)"  # bullfrog.lib.bash et al live here
_FROG_COMMON_JSON_PATH="$(realpath "$_FROG_COMMON_PATH"/json)"  # namespace.cfg.json in json/cfg
_FROG_COMMON_JSON_SCHEMA_PATH="$(realpath "$_FROG_COMMON_PATH"/json/schema)"  # namespace.cfg.schema.json in schema/cfg
_FROG_COMMON_SKELETON_PATH="$(realpath "$_FROG_COMMON_PATH"/skeleton)"  # templates that mirror desired install path

_FROG_NAMESPACE_PATTERN='^([a-z0-9]+\.?)*[a-z0-9]+$'
_FROG_PARAMETER_PATTERN='^--([a-z0-9]+\.?)*[a-z0-9]+$'

_FROG_OPTION_APP="common"
_FROG_OPTION_CONFIG="default"
_FROG_OPTION_FORCE=0
_FROG_OPTION_DEBUG=0
_FROG_OPTION_BASH_DEBUG=0

declare -A _FROG_PACKAGES
declare -A _FROG_NAMESPACES

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