#!/bin/bash
set -oue pipefail

GRN='\033[1;32m'
NC='\033[0m' 

FROG_ROOT="$(frog_rootpath)"
PARAMS=@(recovery-user vm-type)

# Script parameters
RECOVERY_USER="$(frog_param $PARAMS recovery-user)"
VM_TYPE="$(frog_param $PARAMS vm-type)"

function frog_param {

}

function frog_rootpath {
    "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
}

function frogl_bullet {
    echo -e "${GRN}|=== ${1} ...                                                        |${NC}"
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

echo
echo -e "${GRN}++---------------------------------------------------------------------------++${NC}"
echo -e "${GRN}+-------------------------- bullfrog / system / init -------------------------+${NC}"
echo -e "${GRN}|                                                                             |${NC}"

source $FROG_ROOT/bin/system/package/_init.bash

# amazon only ...
echo -e "${GRN}|=== Creating recovery user '${RECOVERY_USER}' ...                                                 |${NC}"
#frog_user_add $RECOVER_USER sudo,ssh
sudo adduser --disabled-password --gecos "" $RECOVERY_USER 
sudo usermod -aG sudo,ssh $RECOVERY_USER
sudo chown -R $RECOVERY_USER:$RECOVERY_USER /home/$RECOVERY_USER
# end of amazon only

# Finish
#frog_dir_secure /home/$RECOVERY_USER $RECOVERY_USER
sudo chown -R $RECOVERY_USER:$RECOVERY_USER /home/$RECOVERY_USER
sudo chmod -R o-rwx /home/$RECOVERY_USER

#frog_sshd_init
#frog_user_sshkey $RECOVERY_USER /home/$RECOVERY_USER/bullfrog-recovery.key

echo -e "${GRN}|=== Altering motd ...                                                        |${NC}"
#frog_system_motd_update
frogl_bullet "Altering motd"
sudo chmod 644 /etc/update-motd.d/*
sudo cp $FROG_ROOT /config/system/motd/00-bullfrog /etc/update-motd.d
sudo chown root:root /etc/update-motd.d/00-bullfrog
sudo chmod 755 /etc/update-motd.d/00-bullfrog

echo -e "${GRN}|=== Installation complete. Perform the following steps:                      |${NC}"
echo -e "${GRN}|       * Set the maintenance user account's password:   sudo passwd frog     |${NC}"
echo -e "${GRN}|       * Login with SSH.                                                     |${NC}"
echo -e "${GRN}|                                                                             |${NC}"
echo -e "${GRN}+-------------------------- installation complete ----------------------------+${NC}"
echo -e "${GRN}+----------------------- end bullfrog / system / init ------------------------+${NC}"
echo -e "${GRN}++---------------------------------------------------------------------------++${NC}"
echo

exit 0
