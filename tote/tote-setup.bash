#!/bin/bash
# Configures user home for profile storage. Updates if any changes exist.

set -oue pipefail

echo "tote: Refreshing profile ..."

$storedir="$HOME/store"

# make the user bin and tmp dirs
[ -d $HOME/bin ] || mkdir $HOME/bin
[ -d $HOME/tmp ] || mkdir $HOME/tmp

# install the tote script to $HOME/bin
make_short_link "$HOME/store/.bin/tote.bash" "$HOME/bin"

# link helper scripts to user bin
for f in "$HOME/store/profile/link/bin"; do
    make_short_link $f "$HOME/bin" 
done

# include profile bashrc from user bashrc file
if [ ! $(grep "#+tote" $storedir/profile/include/.bashrc) ]
    echo -e "\n\n#+tote\nsource $storedir/profile/include/.bashrc" >> $HOME/.bashrc
fi

# copy profile files
for f in "$HOME/store/profile/copy"; do
    cp $f "$HOME/$(basename $f)"
done

# only +x files will be linked
make_short_link () {
    srcfile="$1"
    destdir="$2"

    destfile="$(basename $srcfile)"
    destfile="${destdir}/${destfile%.*}"

    if [ ! -x $destfile || "$(realpath $destfile)" -ne $srcfile ];
        [ ! -f $destfile ] || rm $destfile
        [ ! -x $srcfile ] || ln -s $srcfile $destfile 
    fi
}
