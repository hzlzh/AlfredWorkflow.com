#!/bin/bash

MOBILIZER="http://www.instapaper.com/m?u="
FRONTAPP=$(osascript -e 'tell application "System Events" to return (path to frontmost application as text)')
case $FRONTAPP in
    *Safari* | *WebKit* )
        osascript -e "tell application \"$FRONTAPP\" to set URL of current tab of window 1 to \"$MOBILIZER\" & (URL of current tab of window 1)"
    ;;
    *"Google Chrome"* )
        osascript -e "tell application \"$FRONTAPP\" to set URL of active tab of window 1 to \"$MOBILIZER\" & (URL of active tab of window 1)"
    ;;
    *Opera* )
        osascript -e "tell application \"$FRONTAPP\" to set URL of front window to \"$MOBILIZER\" & (URL of front window)"
    ;;
    *Camino* )
        osascript -e "tell application \"$FRONTAPP\" to set URL of current tab of front browser window to \"$MOBILIZER\" & (URL of current tab of front browser window)"
    ;;
    *OmniWeb* )
        osascript -e "tell application \"$FRONTAPP\" to set address of active tab of front browser to \"$MOBILIZER\" & (address of active tab of front browser)"
    ;;
    * )
        THEURL=$(pbpaste | grep "^[a-zA-Z]*://")
        if [ ! -z "$THEURL" ]
            then
            open "$MOBILIZER$THEURL"
        fi
    ;;
esac
