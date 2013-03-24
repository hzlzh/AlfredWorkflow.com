#!/bin/bash

FRONTAPP=$(osascript -e "tell application \"System Events\" to return (path to frontmost application as text)")
case $FRONTAPP in
    *Safari* | *WebKit* )
        THEURL=$(osascript -e "tell application \"$FRONTAPP\" to return (URL of current tab of window 1 as text)")
        THETITLE=$(osascript -e "tell application \"$FRONTAPP\" to return (name of current tab of window 1 as text)")
    ;;
    *"Google Chrome"* )
        THEURL=$(osascript -e "tell application \"$FRONTAPP\" to return (URL of active tab of window 1 as text)")
        THETITLE=$(osascript -e "tell application \"$FRONTAPP\" to return (title of active tab of window 1 as text)")
    ;;
    *Opera* )
        THEURL=$(osascript -e "tell application \"$FRONTAPP\" to return (URL of front window as text)")
        THETITLE=$(osascript -e "tell application \"$FRONTAPP\" to return (name of front window as text)")
    ;;
    *Camino* )
        THEURL=$(osascript -e "tell application \"$FRONTAPP\" to return (URL of current tab of front browser window as text)")
        THETITLE=$(osascript -e "tell application \"$FRONTAPP\" to return (name of current tab of front browser window as text)")
    ;;
    *OmniWeb* )
        THEURL=$(osascript -e "tell application \"$FRONTAPP\" to return (address of active tab of front browser as text)")
        THETITLE=$(osascript -e "tell application \"$FRONTAPP\" to return (title of active tab of front browser as text)")
    ;;
esac

if [ -z "$THEURL" ] 
    then
    THEURL=$(pbpaste | grep "^[a-zA-Z]*://")
    THETITLE=$THEURL
fi
if [ -z "$THEURL" ] 
    then
    echo "Unable to find a URL."
else
    case "$1" in
        markdown )
            $(echo "[$THETITLE]($THEURL)" | pbcopy)
        ;;
        * )
            $(echo "<a href=\"$THEURL\">$THETITLE</a>" | pbcopy)
        ;;
    esac
fi
