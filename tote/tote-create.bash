#!/bin/bash
# Performs first time creation of user profile storage.

set -oue pipefail
IFS=$'\n\t'

echo "tote: Creating tote store ..."

username="$(whoami)"
if [ ! $(git config --global user.name) ]; then
    git config --global user.name "$username"
    git config --global user.email "$username@localhost"
fi


storedir="$HOME/store"
datadirs=(audio document image note profile project)
profiledirs=(copy include link link/bin)

# create storedir. backup existing if necessary.
if [ -d $storedir ]; then
    if [ -d $storedir/encrypted ]; then
        r=$(umount $storedir/encrypted)
    fi
    oldstoredir="$storedir.old.$(date +%s)"
    mv $storedir $oldstoredir
fi

mkdir -p $storedir

# make datadirs within the store directory
cd $storedir
mkdir -p ${datadirs[*]}
cd $storedir/profile
mkdir -p ${profiledirs[*]}

# git init the store/profile/link/bin
cd $storedir/profile/link/bin
git init . 1>/dev/null
touch .gitignore
git add .
git commit -m 'init' 1>/dev/null

# create and mount the encrypted directory
cd $storedir
mkdir -p $storedir/.encfs $storedir/encrypted
encfs --paranoia $storedir/.encfs $storedir/encrypted 1>/dev/null

# make separate datadirs within the encrypted directory
cd $storedir/encrypted
mkdir -p ${datadirs[*]}
cd $storedir/encrypted/profile
mkdir -p ${profiledirs[*]}

# git init the store/encrypted/profile/link/bin
cd $storedir/encrypted/profile/link/bin
git init . 1>/dev/null
touch .gitignore
git add .
git commit -m 'init' 1>/dev/null

cd
mkdir -p $HOME/bin
mkdir -p $HOME/tmp

echo "tote: Store creation succesful."

exit 0
