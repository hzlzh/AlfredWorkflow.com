#!/bin/bash

# we want case-insensitive matching
shopt -s nocasematch

QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

echo "<?xml version=\"1.0\"?>"
echo "<items>"

# ALL Desktop Related Items
if [[ $(defaults read com.apple.finder CreateDesktop) == 1 ]]
then
    ## Hide All Desktop Icons
    TITLE="Hide All Desktop Icons"
    if [[ " $TITLE" == *\ $QUERY* ]]
        then
        echo "<item uid=\"hide desktop icons\" arg=\"hideDesktopIcons\">"
        echo "<title>Hide All Desktop Icons</title>"
        echo "<subtitle>Icons will still be available in ~/Desktop</subtitle>"
        echo "<icon>desktop.png</icon></item>"
    fi

    ## The Other Desktop Items
    for PROPERTY in 'ShowExternalHardDrivesOnDesktop' 'ShowHardDrivesOnDesktop' 'ShowMountedServersOnDesktop' 'ShowRemovableMediaOnDesktop'
    do

        if [[ $(defaults read com.apple.finder $PROPERTY) == 1 ]]
            then
            PROPERTY="Hide${PROPERTY:4}"
        fi

        TITLE=$(echo $PROPERTY | sed -e 's/\([[:upper:]]\)/ \1/g' -e 's/^ //g' )
        if [[ " $TITLE" == *\ $QUERY* ]]
            then
            echo "<item uid=\"$PROPERTY\" arg=\"$PROPERTY\"><title>$TITLE</title><subtitle></subtitle><icon>desktop.png</icon></item>"
        fi

done

else
## Show All Desktop Icons
    TITLE="Show All Desktop Icons"
    if [[ " $TITLE" == *\ $QUERY* ]]
        then
        echo "<item uid=\"show desktop icons\" arg=\"showDesktopIcons\">"
        echo "<title>Show All Desktop Icons</title>"
        echo "<subtitle>Show Icon on the Desktop</subtitle>"
        echo "<icon>desktop.png</icon></item>"
    fi
fi

echo "</items>"
shopt -u nocasematch
