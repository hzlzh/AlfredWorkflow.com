#!/bin/bash

# cases that handles fetching the URL them self
case "$1" in
    instapapermobilizer )
        sh mobilize.sh
        ;;
    markdownlink )
        sh createLink.sh "markdown"
        ;;
    htmllink )
        sh createLink.sh
        ;;
    *)
        # all other options need the URL, so lets fetch it
        THEURL=$(sh getURL.sh)
        # if no url then just exit
        if [ -z "$1" ]
            then
            echo "Unable to find a URL"
            exit
        fi

        case "$1" in
        adium* )
            # send the url as a chat message to chosen Adium contact
           USER=$(echo "$1" | sed -e 's/^adium//')
            osascript<<END
                tell application "Adium"
                    activate
                    set user to first contact whose status type is not offline and (display name contains "$USER" or name contains "$USER")
                    
                    if not (exists (chats whose contacts contains user)) then
                        
                        tell account of user to (make new chat with contacts {user} with new chat window)
                        
                    end if
                    
                    send (first chat whose contacts contains user) message "$THEURL"
                    
                    tell (first chat whose contacts contains user) to become active
                    
                end tell
END
            ;;
        com.sparrowmailapp.sparrow )
            # Insert the URL into a new mail in Sparrow as a html link
            osascript -e "tell application \"Sparrow\" to compose (make new outgoing message with properties {htmlContent:\"<br /><a href=\\\"$THEURL\\\">$THEURL</a>\"})" -e "tell application \"Sparrow\" to activate"
            ;;
        com.apple.mail )
            # Insert the URL into a new mail in Mail as text
            osascript -e "tell application \"Mail\" to (make new outgoing message with properties {visible:true, content:return & \"$THEURL\" & return & return})" -e "tell application \"Mail\" to activate"
            ;;
        com.postbox-inc.postbox )
            # Insert the URL into a new mail in Postbox as text
            osascript -e "tell application \"Postbox\" to send message body \"$THEURL\"" -e "tell application \"Postbox\" to activate"
            ;;
        com.tapbots.TweetbotMac )
            open $(php -r "echo 'tweetbot:///post?text=' . urlencode(\"$THEURL\");")
            ;;
        com.droplr.droplr-mac )
            # shorten link with Droplr       
            if [[ $(ps aux | grep "Droplr" | egrep -cv "grep|actionurl.sh") -lt 1  ]]
                then
                open -gb "$1"
                sleep 3
            fi
                osascript -e "tell application \"Droplr\" to shorten \"$THEURL\""
            ;;
        pbcopy )
            # copy to clipboard
            echo "$THEURL" | pbcopy;
            ;;
        gmail )
            # compose a new Gmail mail with the url in as text
            open "https://mail.google.com/mail/?view=cm&fs=1&body=$THEURL"
            ;;
        downforeveryoneorjustme )
            # check downforeveryoneorjustme.com and return answer in notification
            THEURL=$(echo $THEURL | grep -o "^.*://[^/]*")
            ISUP=$(curl "http://www.downforeveryoneorjustme.com/$THEURL")
            if [[ $(echo "$ISUP" | grep -c "It's just you.") == 1 ]]
                then 
                echo "It's just you."
                echo "\"${THEURL}\" is up."
            elif [[ $(echo "$ISUP" | grep -c "It's not just you!") == 1 ]]
                then
                echo "It's not just you!"
                echo "\"${THEURL}\" seems to be down."
            else
                echo "Unable to check if \"$THEURL\" is up"
            fi
        ;;
        *)
            # all other applications can be opened from bash
            open -b "$1" "$THEURL"
            ;;
    esac

    ;;
esac
# reload the application cache
sh cacheApps.sh
