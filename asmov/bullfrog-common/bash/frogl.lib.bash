#!/bin/bash
set -o allexport -o errexit -o privileged -o pipefail -o nounset 

frogl_bullet () {
        printf "${FROGL_GRN}|=== ${1}%s*|${FROG_NC}" " " $(eval length $1 - 82 - 1) 
}

function frogl_start {
    echo
    echo -e "${GRN}++---------------------------------------------------------------------------++${NC}"
    echo -e "${GRN}+-------------------------- ${1} -------------------------+${NC}"
    echo -e "${GRN}|                                                                             |${NC}"
}

function frogl_header {
        echo
}

function frogl_footer {
        echo
}

function frogl_end {
        echo
}

_FROGL_GRN='\033[1;32m'
_FROGL_NC='\033[0m' 
