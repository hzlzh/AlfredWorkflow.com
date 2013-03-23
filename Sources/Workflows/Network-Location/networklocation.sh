#!/bin/bash

# we want case-insensitive matching
shopt -s nocasematch

# remove pending and trailing whitespace and replace other whitespace with *
QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

# get the current location
CURRENT_LOCATION=$(networksetup -getcurrentlocation)

echo '<?xml version="1.0"?>'
echo "<items>"

networksetup -listlocations | while read LOCATION
do
    if [[ " $LOCATION" == *\ $QUERY* ]]
        then
        
        if [[ "$LOCATION" == "$CURRENT_LOCATION" ]]
            then
            echo '<item uid="networklocation selected" valid="no">'
            echo "<title>$LOCATION (selected)</title>"
        else
            echo "<item uid=\"networklocation $LOCATION\" arg=\"$LOCATION\">"
            echo "<title>$LOCATION</title>"
        fi
        echo "<subtitle>Network Location</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi
done

echo "</items>"

shopt -u nocasematch
