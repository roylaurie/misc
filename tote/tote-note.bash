#!/bin/bash

echo -n "Title:  "
read noteTitle

titleSlug="$(echo ${noteTitle} | sed -e 's/ /-/g' | sed -e 's/[^a-zA-Z0-9\-]//g')"
noteFilepath="${HOME}/store/note/${titleSlug,,}.md"

if [ ! -f $noteFilepath ]; then
    datestamp="$(date +%Y-%m-%d)"
    echo -e "= ${noteTitle^}\n_${datestamp}_\n\n" > $noteFilepath
fi

vim + +start $noteFilepath
