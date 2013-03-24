#!/bin/bash

# check for a recent cached url, only if "no cache" is not set
let "TIME=$(date +%s)-2" # keep url cache in 2 seconds
if [ "$1" != "nocache" ] && [ $(stat -f "%m" ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/url) -ge $TIME ]
    then
    touch ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/url
    head -1 ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/url
else
# no cache, fetch url from frontmost browser
    FRONTAPP=$(osascript scpt/getFrontMostApp.scpt)
    case $FRONTAPP in
        Safari )
            THEURL=$(osascript scpt/fetchURLfromSafari.scpt)
        ;;
        SafariForWebKitDevelopment | WebKit )
            THEURL=$(osascript scpt/fetchURLfromWebKit.scpt)
        ;;
        "Google Chrome Canary" )
            THEURL=$(osascript scpt/fetchURLfromChromeCanary.scpt)
        ;;
        "Google Chrome" )
            THEURL=$(osascript scpt/fetchURLfromChrome.scpt)
        ;;
        Opera )
            THEURL=$(osascript scpt/fetchURLfromOpera.scpt)
        ;;
        Camino )
            THEURL=$(osascript scpt/fetchURLfromCamino.scpt)
        ;;
        OmniWeb )
            THEURL=$(osascript scpt/fetchURLfromOmniWeb.scpt)
        ;;
    esac

    if [ -z "$THEURL" ]
        then
        # no browser is supported frontmost, check if the clipboard has an url
        THEURL=$(pbpaste | grep "^[a-zA-Z]*://")
        if [ -z "$THEURL" ]
            then
            # no url found - exit
            exit
        fi
    fi
    # cache the url
    if [ ! -d ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/ ]
        then
        mkdir ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL
    fi
    echo $THEURL > ~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/url
    # return the url
    echo $THEURL
fi
