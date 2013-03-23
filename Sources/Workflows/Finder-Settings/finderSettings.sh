#!/bin/bash

# we want case-insensitive matching
shopt -s nocasematch

QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

echo "<?xml version=\"1.0\"?>"
echo "<items>"

# Show/Hide Hidden Files
if [[ $(defaults read com.apple.finder AppleShowAllFiles) == 1 ]]
    then
    TITLE="Hide System Files"
    SUBTITLE="Don't show hidden files in Finder"
    ARG="hideHiddenFiles"
else
    TITLE="Show System Files"
    SUBTITLE="Show hidden files in Finder"
    ARG="showHiddenFiles"
fi

if [[ " $TITLE hidden" == *\ $QUERY* ]]
    then
    echo "<item uid=\"$ARG\" arg=\"$ARG\">"
    echo "<title>$TITLE</title>"
    echo "<subtitle>$SUBTITLE</subtitle>"
    echo "<icon>icon.png</icon></item>"
fi

# Show/Hide users Library folder
if [[ $(ls -lO ~/ | grep " Library" | grep -c "hidden") == 1 ]]
    then
    TITLE="Show User Library Folder"
    ARG="showLibraryFolder"
else
    TITLE="Hide User Library Folder"
    ARG="hideLibraryFolder"
fi

if [[ " $TITLE" == *\ $QUERY* ]]
    then
    echo "<item uid=\"$ARG\" arg=\"$ARG\">"
    echo "<title>$TITLE</title>"
    echo "<subtitle>~/Library</subtitle>"
    echo "<icon>icon.png</icon></item>"
fi

# Rebuild Launch Services (Open With... Menu)
    ARG="rebuildLaunchServices"
    TITLE="Rebuild Launch Services"

if [[ " $TITLE" == *\ $QUERY* ]]
    then
    echo "<item uid=\"$ARG\" arg=\"$ARG\">"
    echo "<title>$TITLE</title>"
    echo "<subtitle>Cleans up the \"Open With..\" menu</subtitle>"
    echo "<icon>icon.png</icon></item>"
fi

echo "</items>"
shopt -u nocasematch
