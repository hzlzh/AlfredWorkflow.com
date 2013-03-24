#!/bin/bash

# we want case-insensitive matching
shopt -s nocasematch

# get the url
if [ -z "$1" ]
   then
    THEURL=$(sh getURL.sh nocache)
else
    THEURL=$(sh getURL.sh)
fi

THEURL=$(echo "$THEURL" | sed -e 's/&/&amp;/g')
URLFILEFORMAT=$(echo $THEURL | sed 's/^.*\(\.[^.]*$\)/\1/')
URLPROTOCOL=${THEURL%"://"*}

CACHEFILE=~/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow\ Data/dk.aiyo.SendURL/appCache.db
if [[ ! -f "$CACHEFILE" ]]
    then
    # if there is not application cache then create it
    sh cacheApps.sh
fi
# strip leading an tailing whitespace and change whitespace between word with * to prepare for matching
QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

echo "<?xml version=\"1.0\"?>"
echo "<items>"

# make sure there is a URL to grab
if [[ -z "$THEURL" ]]
    then
    # if no URL then display an error
    echo "<item uid=\"\" arg=\"\" valid=\"no\">"
    echo "<title>Send URL to...$QUERY</title>"
    echo "<subtitle>Unable to find a URL!</subtitle>"
    echo "<icon>icon.png</icon>"
    echo "</item>"

# special case for Adium
elif [[ $QUERY* == "adium"* ]] && [[ $(ps ax | grep -c Adium) -ge 2 ]]
    then
    # List active Adium contacts
    USERS=$(osascript -e "tell application \"Adium\" to return display name of every contact whose status type is not offline" | sed -e 's/, /,/g' |  tr " " "_" | tr "," "\n" | sort -u )

    for USER in $USERS
    do
        USERNAME=$(echo $USER | tr '_' ' ' | sed 's/^\ //')
        if [[ "adium $USERNAME" == $QUERY* ]]
            then
            echo "<item uid=\"\" arg=\"adium$USERNAME\" autocomplete=\"Adium $USERNAME\">"  
            echo "<title>Send URL to $USERNAME</title>"
            echo "<subtitle>Send URL in a chat message</subtitle>"
            echo "<icon>Adium.png</icon>"
            echo "</item>"
        fi
    done

# List all avaiable applications
else
    # use timestamp and a iterator as uid to make the list order static
    TIMESTAMP=$(date +%s)
    i=1
    # Copy to clipboard item, on top when no $query
    if [[ "copy" == $QUERY* ]]
        then
        echo "<item uid=\"$TIMESTAMP\" arg=\"pbcopy\" autocomplete=\"Copy\">"
        echo "<title>$THEURL</title>"
        echo "<subtitle>Copy URL...</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi

    # Get the apps from the db, but only if the match the query
    DB_QUERY="% "$(echo "$1" | sed -e 's/\*/%/g')"%"
    sqlite3 "$CACHEFILE" "select ID, Name, Path from apps where (NameCaps like '$DB_QUERY' OR NameSplit like '$DB_QUERY' OR Name like '$DB_QUERY') AND (Formats like '%$URLFILEFORMAT%' OR Formats='*')" | while read APP
    do
        APP_PATH=${APP##*"|"}
        APP=${APP%"|"*}
        APP_ID=${APP%"|"*}
        APP_NAME=${APP#*"| "}

        echo "<item uid=\"$TIMESTAMP$i\" arg=\"$APP_ID\" autocomplete=\"$APP_NAME\">
            <title>Send URL to $APP_NAME</title>
            <subtitle>$APP_PATH</subtitle>
            <icon type=\"fileicon\">$APP_PATH</icon>
            </item>"
        let "i+=1"
    done
 
    # adium item
    if [[ "adium" == $QUERY* ]] && [[ $(ps ax | grep -c Adium) -ge 2 ]]
        then
        echo "<item uid=\"$TIMESTAMP$i\" autocomplete=\"Adium \" valid=\"no\" >"
        echo "<title>Send URL to Adium</title>"
        echo "<subtitle>Send URL to a Contact</subtitle>"
        echo "<icon>Adium.png</icon>"
        echo "</item>"
        let "i+=1"
    fi    

    # compose gmail message with url
    if [[ "gmail" == $QUERY* ]]
        then
        echo "<item uid=\"$TIMESTAMP$i\" arg=\"gmail\" autocomplete=\"Gmail\">"
        echo "<title>Send URL to Gmail</title>"
        echo "<subtitle>https://mail.google.com/</subtitle>"
        echo "<icon>gmail.png</icon>"
        echo "</item>"
        let "i+=1"
    fi

    # Instapaper Mobilizer
    if [[ " instapaper mobilizer" == *\ $QUERY* ]] && [[ $URLPROTOCOL == http* ]]
        then
        echo "<item uid=\"$TIMESTAMP$i\" arg=\"instapapermobilizer\" autocomplete=\"Mobilizer\">"
        echo "<title>Send URL to Instapaper Mobilizer</title>"
        echo "<subtitle>Opens Instapaper Mobilizer in the default browser</subtitle>"
        echo "<icon>instapaper.png</icon>"
        echo "</item>"
    fi

    # downforeveryoneorjustme item
    if [[ " down for everyone or just me" == *\ $QUERY* ]]
        then
        echo "<item uid=\"$TIMESTAMP$i\" arg=\"downforeveryoneorjustme\" autocomplete=\"Down For Everyone?\">"
        echo "<title>Down For Everyone Or Just Me?</title>"
        echo "<subtitle>http://www.downforeveryoneorjustme.com</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
        let "i+=1"
    fi

    # Copy to clipboard as html link item
    if [[ " copy as html link" == *\ $QUERY* ]]
        then
        echo "<item uid=\"$TIMESTAMP$i\" arg=\"htmllink\" autocomplete=\"Copy as HTML link\">"
        echo "<title>Copy URL as HTML Link...</title>"
        echo "<subtitle>Create a HTML link tag from the URL</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi

    # Copy to clipboard as markdown link item
    if [[ " copy as markdown link" == *\ $QUERY* ]]
        then
        echo "<item uid=\"$TIMESTAMP$i\" arg=\"markdownlink\" autocomplete=\"Copy as Markdown link\">"
        echo "<title>Copy URL as Markdown Link...</title>"
        echo "<subtitle>Create a Markdown link from the URL</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi

    # Copy to clipboard item, on bottom $query in not empty
    if [[ "copy" != $QUERY* ]]
        then
        echo "<item uid=\"$TIMESTAMP$i\" arg=\"pbcopy\" autocomplete=\"Copy\" >"
        echo "<title>$THEURL</title>"
        echo "<subtitle>Copy URL...</subtitle>"
        echo "<icon>icon.png</icon>"
        echo "</item>"
    fi
fi
echo "</items>"
shopt -u nocasematch
