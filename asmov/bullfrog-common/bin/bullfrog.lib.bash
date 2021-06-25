#!/bin/bash

set -oue pipefail

FROG_ROOT="$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
FROG_USER="frog"

FROGL_GRN='\033[1;32m'
FROGL_NC='\033[0m' 

function frogl_bullet {
        printf "${FROGL_GRN}|=== ${1}%s*|${FROG_NC}" " " $(eval length $1 - 82 - 1) 
}

function frogl_start {
    echo
    echo -e "${GRN}++---------------------------------------------------------------------------++${NC}"
    echo -e "${GRN}+-------------------------- ${1} -------------------------+${NC}"
    echo -e "${GRN}|                                                                             |${NC}"
}

function frogl_header {
}

function frogl_footer {
}

function frogl_end {
}


