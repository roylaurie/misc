#!/bin/bash

totebin="$HOME/store/.bin"
action="$1"

case $action in
    "setup" | "refresh")
        bash $totebin/tote-setup.bash $2-
        ;;
    "note")
        bash $totebin/tote-note.bash $2-
        ;;
    "notes")
        bash $totebin/tote-notes.bash
        ;;
    *)
        echo "Unknown command"
        exit 1
        ;;
esac
exit 0
