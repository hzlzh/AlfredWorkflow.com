#Prefs folder
DIALWD="$HOME/Library/Application Support/Alfred 2/Workflow Data/carlosnz.dialler"

#help?
if [ "$1" = help ]; then
	open ./docs/help.html
	echo -n "Help page displayed in browser"
	exit
fi 

#Get current (if any) API key
PROWL_API_KEY=$(cat "$DIALWD/api_key")

script_string="tell app \"System Events\" to display dialog \"Please enter your Prowl API key.\n\nIf you don't have one yet, “Cancel” now and you will be directed to the appropriate web page.\" default answer \"$PROWL_API_KEY\n\" with title \"Dial with iPhone\" with icon POSIX file \"$PWD/icon.icns\""

#check for API key or user input "setup"
if [ ! -e "$DIALWD/api_key" ] || [ $1 = setup ]; then
	PROWL_API_KEY=$(osascript -e "$script_string")
	if [ -z $PROWL_API_KEY ]; then
		#go to website
		open https://www.prowlapp.com/api_settings.php
	else
		#strip crap from Applescript output - SURELY there's a nicer way to do this, but buggered if I can google it.
		PROWL_API_KEY=${PROWL_API_KEY/text returned:/}
		PROWL_API_KEY=${PROWL_API_KEY/, button returned:OK/}
		#Save key
		mkdir "$DIALWD"
		echo -n $PROWL_API_KEY > "$DIALWD/api_key"
		echo "API key saved. You can now send phone numbers to your iPhone."
	fi
	exit
fi


#just dial a fucking number already.
PROWL_API_KEY=$(cat "$DIALWD/api_key")

phoneno=$(echo "$1" | tr -d ' ')	#strip spaces from Phone no.

#Check that we're left with only digits (and valid punctuation: + ( ) * # ; )
if [[ $phoneno = *[!0-9,+,\(,\),\*,#,\;,-,\[,\]]* ]]; then
	echo "Sorry, \""$1"\" is not a valid phone number."
	exit
fi

RESULT=$(curl -s -k https://prowl.weks.net/publicapi/add -F apikey=$PROWL_API_KEY -F application="Alfred" -F event="Open to call:" -F description="$1" -F url="tel://$phoneno")

if [[ "$RESULT" =~ "<success code=\"200\"" ]]; then
	echo "The number $1 was successfully sent to your iPhone"
else
	echo "Oops. There was a problem. Number not sent."
fi