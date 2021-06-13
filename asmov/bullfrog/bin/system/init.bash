#!/bin/bash
set -oue pipefail
IFS=$'\n\t'

GRN='\033[1;32m'
NC='\033[0m' 

FROG_ROOT="$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
FROG_USER="frog"

echo -e "\n"
echo -e "${GRN}+-----------------------------------------------------------------------------+${NC}"
echo -e "${GRN}+----------------------------------bullfrog-----------------------------------+${NC}"
echo -e "${GRN}+-----------------------------------system------------------------------------+${NC}"
echo -e "${GRN}|                                                                             |${NC}"

source $FROG_ROOT/bin/system/package/_init.bash

echo -e "${GRN}|=== Creating user 'frog' ...                                                 |${NC}"
sudo adduser --disabled-password --disabled-login --gecos "" $FROG_USER 
sudo usermod -aG sudo $FROG_USER
sudo chown -R $FROG_USER:$FROG_USER /home/$FROG_USER

# Finish
sudo chown -R $FROG_USER:$FROG_USER /home/$FROG_USER
sudo chmod -R o-rwx /home/$FROG_USER

echo -e "${GRN}|=== Altering motd ...                                                        |${NC}"
sudo chmod 644 /etc/update-motd.d/*
sudo cp $FROG_ROOT /config/system/motd/00-bullfrog /etc/update-motd.d
sudo chown root:root /etc/update-motd.d/00-bullfrog
sudo chmod 755 /etc/update-motd.d/00-bullfrog

echo -e "${GRN}|=== Installation complete. Perform the following steps:                      |${NC}"
echo -e "${GRN}|       * Set the maintenance user account's password:   sudo passwd frog     |${NC}"
echo -e "${GRN}|       * Login with SSH.                                                     |${NC}"
echo -e "${GRN}|                                                                             |${NC}"
echo -e "${GRN}+-----------------------------------------------------------------------------+${NC}"
echo -e "${GRN}+---------------------------installation-complete-----------------------------+${NC}"
echo -e "${GRN}+-----------------------------------------------------------------------------+${NC}"
echo

exit 0
