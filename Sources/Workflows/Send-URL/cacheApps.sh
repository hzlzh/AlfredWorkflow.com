#!/bin/bash

CACHEFILE=~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/appCache.db

# if the database exists, remove it
if [[ -f "$CACHEFILE" ]]
    then
    rm "$CACHEFILE"
fi
# create a new database
sqlite3 "$CACHEFILE" 'create table apps(ID text, Path text, NameCaps text, NameSplit text, Name text, Formats text)'

# loop through the list of supported apps
while read LINE
do
    APP_ID=${LINE%,*}
    APP_FILEFORMATS=${LINE#*,}
    # use mdfind to find the path
    APP_PATH=$(mdfind "kMDItemCFBundleIdentifier == '$APP_ID'" | head -n 1)
    # if no path - the app is not on the system, skip to next app on the list
    if [[ ! -z "$APP_PATH" ]]
        then
        # once we have the path we can find the display name and divide it up preparing for fuzzy match
        APP_NAME=" "$(mdls -name "kMDItemDisplayName" "$APP_PATH" | sed -e 's/^[^"]*"//' -e 's/"$//'  -e 's/\.app//')
        APP_CAPS=" "$(echo "$APP_NAME" | sed -e 's/[a-z \.]*//g')
        APP_SPLIT=$(echo "$APP_NAME" | sed -e 's/\([^ ]\)\([A-Z]\)/\1 \2/g')
        # save it all
        sqlite3 "$CACHEFILE" "insert into apps (ID,Path,NameCaps,NameSplit,Name,Formats) values('$APP_ID','$APP_PATH','$APP_CAPS','$APP_SPLIT','$APP_NAME', '$APP_FILEFORMATS');"
    fi
done < supportedApplications.txt
