#!/bin/bash
# Lists all tote notes and allows one to be edited by selection.

set -oue pipefail

allnotes=($(ls -t $HOME/store/note | xargs -n1 basename -s ".md"))
numnotes=${#allnotes[@]}
ns=0
nl=$(( numnotes > 10 ? 10 : numnotes ))
notes="${allnotes[@]:$ns:$nl}"

if [ $nl -gt 10 ]; then
    PS3="Note (< j k >): "
else
    PS3="Note: "
fi

while [ true ]; do
        select note in $notes; do
            if [ $REPLY ==  "j" ]; then 
                ns=$(( (ns - 1) * nl ))
                (( ns >= 0 )) || ns=$(( (numnotes - nl) * nl ))
                notes="${allnotes[@]:$ns:$nl}"
                break
            elif [ $REPLY == "k" ]; then
                ns=$(( (ns + 1) * nl ))
                (( ns < ${#allnotes[@]} )) || ns=0
                notes="${allnotes[@]:$ns:$nl}"
                break
            else
                vim + $HOME/store/note/${note}.md
                exit 0;
            fi
        done
done

exit 0
