#!/bin/bash

source includes.sh

#Ask for folder (via Applescript GUI)
user_path=$(osascript <<-EOF

tell application "System Events"
	activate
	set folderName to POSIX path of (choose folder with prompt "Choose location for your stored Timezones list")
end tell

EOF)

if [ -z $user_path ]; then
	exit
fi

#Move timezones.txt
mv "$timezone_file" "$user_path"

#If file operation successful
if [ $? = 0 ]; then
	#Update config file with new path
	echo "$user_path/timezones.txt" > "$TZPREFS/config"
	
	#Notify
	echo -n "File successfully moved to new location."
else
	#Notify
	echo -n "Sorry, unable to move to that location."
fi

exit