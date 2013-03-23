#!/bin/bash

# we want case-insensitive matching
shopt -s nocasematch

# remove pending and trailing whitespace and replace other whitespace with *
QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')
# find out who is current user
ME=$(whoami)
# directory to store cached user icons
CACHEDIR="$(dscl . -read /Users/$ME/ NFSHomeDirectory | sed -e 's/^[^:]*: //')/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/dk.aiyo.fastUserSwitching"

echo "<?xml version=\"1.0\"?>"
echo "<items>"

# list user accounts
GUESTENABLED=$(defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled)
USERS=$(dscl . -list /Users _writers_UserCertificate | sed 's/ .*$//')
for USERNAME in $USERS
    do 
    # only list user who is not current and only list guest user if enabled
    if [[ "$USERNAME" != "$ME" ]] && [[ "$USERNAME" != "Guest" || $GUESTENABLED == 1 ]]
        then
        # Get the real name of the account
        REALNAME=$(dscl . -read /Users/$USERNAME/ RealName | tail -n 1 | sed -e 's/^RealName: //' -e 's/^ *//')

    # user picture
        # first check cache
        let "TIME=$(date +%s)-600" # cached icon timeout - 10 minutes
        if [[ -f "$CACHEDIR/$USERNAME.jpg"  && $(stat -f "%m" "$CACHEDIR/$USERNAME.jpg") -ge $TIME ]]
            then
            PICTURE="$CACHEDIR/$USERNAME.jpg"
        # if no recent cache then check for jpeg image
        elif [[ ! -z $(dscl . -read "/Users/$USERNAME/" JPEGPhoto | head -1) ]]
            then
            # make directory for icon cache if it do not exists
            if [[ ! -d "$CACHEDIR" ]]
                then
                mkdir "$CACHEDIR"
            fi
            # cache the user icon
            dscl . -read "/Users/$USERNAME/" JPEGPhoto | tail -1 | xxd -r -p > "$CACHEDIR/$USERNAME.jpg"
            # and get the path to the cache
            PICTURE="$CACHEDIR/$USERNAME.jpg"
        # if no jpeg image check for the Picture parameter
        elif [[ ! -z $(dscl . -read "/Users/$USERNAME/" Picture | head -1) ]]
            then
            PICTURE=$(dscl . -read "/Users/$USERNAME/" Picture | tail -n 1 | sed 's/^[ \t]*//')
        # if not picture - use default (workflow icon)
        else
            PICTURE="icon.png"
        fi
        # check if the user is logged in, if so then add (logged in) to the name
        if [[ $(who | grep -c "^$USERNAME ") -gt 0 ]]
            then
            LOGINSTATUS="(logged in)"
        else
            LOGINSTATUS=""
        fi
        # fuzzymatch with real name and username 
        if [[ " $REALNAME" == *\ $QUERY* || $USERNAME == $QUERY* ]]
            then
            # if match is found display the user
            echo "<item uid=\"fastuserswitch $USERNAME\" arg=\"$USERNAME\">"
            echo "<title>$REALNAME</title><subtitle>Switch to $REALNAME $LOGINSTATUS</subtitle>"
            echo "<icon>$PICTURE</icon></item>"
        fi
    fi
done

# login window
if [[ " Login Window" == *\ $QUERY* ]]
    then
    echo "<item uid=\"fastuserswitch LoginWindow\" arg=\"LoginWindow\">"
    echo "<title>Login Window...</title><subtitle>Switch to Login Window</subtitle>"
    echo "<icon>icon.png</icon></item>"
fi

echo "</items>"

shopt -u nocasematch
