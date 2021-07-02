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

_FROG_IMPORTS=()

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

frog_basepath () {
    echo "$_FROG_BASEPATH"
}

frog_common_path () {
    echo "$_FROG_COMMON_PATH"
}

frog_local_path () {
    echo "$_FROG_LOCAL_PATH"
}

frog_remote_path () {
    echo "$_FROG_REMOTE_PATH"
}

frog_import_namespace () {
    local _json _jsonPath
    _jsonPath="$(realpath "$1"/namespace.json)"
    _json="$(cat $_jsonPath | jq -c 2>&1)" || frog_error $? "Unable to parse json file" $_jsonPath "jq> $_json"
    _FROG_IMPORTS+=("$_json")
}

frog_import_builtin () {
    local _dirs
    _dirs="$(find $(frog_basepath) -maxdepth 1 -name 'bullfrog-*' -type d | xargs realpath | xargs -n 1 -I '_path' find _path/bash -maxdepth 1 -name 'namespace.min.json' 2>/dev/null)" || {
        local _exit=$?
        [ $_exit -ne 0 ] && [ $_exit -ne 123 ] && {
           frog_error 1 "Unable to search for namespaces" 
        }
    }

    for _dir in "$_dirs"; do
        frog_import_namespace "$(realpath $(dirname $_dir))" 
    done
}

##
# Uses the jq tool to query json for data
# @param string json
# @param string query
# @returns string data
##
frog_jq () {
    local _json _query _result
    _json="$1"
    _query="$2"
    _result="$(echo $_json | jq -rc $_query 2>&1)" || frog_error "$?" "Unable to parse js query" "$_query" "json> $_json\njq> $_result"
    echo $_result
}

#$_FROG_CMDLINE_OPTIONS=("help")

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
    local _cmdline=($@) _forOption="" _options=() _optionVals=() _namespace="" _operation="" _params=""

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

    local _operationCfg
    _operationCfg="$(frog_operation_cfg "$_namespace" "$_operation")" || frog_error $?

    local _parameterJson
    #_parameterJson="$(frog_parse_parameters "$_operationCfg")"

    local _result
    #merge _optionJson and _parameterJson into operationCfg
    #echo "$_result"

    echo "$(frog_jq "$_operationCfg" "")" || frog_error $?
}

frog_tty () {
    echo "TTY] $@" > /dev/tty
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

    for _import in "${_FROG_IMPORTS[@]}"; do
        local _opJson
        _opJson="$(frog_jq "${_import}" ".namespaces[].modules[\"$_namespace\"].operations[\"$_operation\"]")" 
        if [ -n "$_opJson" ] && [[ "$_opJson" != "null" ]]; then
            local _namespacePath _bashPath _modulePath _opPath _result
            _namespacePath="$(frog_jq "$_import" ".path")" || frog_error $?
            _bashPath="$(frog_jq "$_import" ".bashPath")" || frog_error $?
            _modulePath="$(frog_jq "$_import" ".namespaces[].modules[\"$_namespace\"].script")" || frog_error $?
            _opPath="$(frog_basepath)/$_namespacePath/$_bashPath/$_modulePath"
            _result="{ \"namespace\": \"$_namespace\", \"operation\": \"$_operation\", \"path\": \"$_opPath\", \"operationCfg\": $_opJson }"
            echo "$_result"
            return 0
        fi
    done

    frog_error 1 "Invalid namespace / operation" "${_namespace}::${_operation}"
}

frog_run_operation () {
    local _cmdCfg _scriptPath
    _cmdCfg="$1"
    _scriptPath="$(frog_jq "$_cmdCfg" ".path")" || frog_error $?
    _opFunc="$(frog_jq "$_cmdCfg" ".operationCfg.function")" || frog_error $?
    #_params="$(frog_jq "$_cmdCfg" ".parameters")"

    source $_scriptPath
    $_opFunc
}

_FROG_ERROR_CODE=64

frog_error () {
    [ "$1" -eq "$_FROG_ERROR_CODE" ] && exit $_FROG_ERROR_CODE

    local _exitCode _errorMessage _subject="" _errorDetails="" _subjectStr=""
    _exitCode="$1"
    _errorMessage="$2"
    [ -n "${3-}" ] && _subject="$3" && _subjectStr=" '$(frog_color lightcyan)${_subject}$(frog_color end)'"
    [ -n "${4-}" ] && _errorDetails="$4"

    $(1>&2 echo -e "$(frog_color red)bullfrog error($(frog_color lightgray)${_exitCode}$(frog_color red)):$(frog_color end) ${_errorMessage}${_subjectStr}")
    [ -n "$_errorDetails" ] && {
        for _line in "$_errorDetails"; do
            $(1>&2 echo -e "$(frog_color red)::$(frog_color end)  $(frog_color lightgray)${_line}$(frog_color end)")
        done
    }

    exit $_FROG_ERROR_CODE 
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

    [ -n "$_color" ] || frog_error 1 "Invalid color" "$_colorName" "frog_color"
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

_FROG_BASEPATH="$(realpath $(frog_script_dir)/../../..)"

_FROG_COMMON_PATH="$(realpath $_FROG_BASEPATH/bullfrog-common)/bash"
_FROG_LOCAL_PATH="$(realpath $_FROG_BASEPATH/bullfrog-local)/bash"
_FROG_REMOTE_PATH="$(realpath $_FROG_BASEPATH/bullfrog-remote)/bash"

source $_FROG_COMMON_PATH/lib/frogl.lib.bash
source $_FROG_COMMON_PATH/lib/frogsh.lib.bash
source $_FROG_COMMON_PATH/lib/frogsys.lib.bash
