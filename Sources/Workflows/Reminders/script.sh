#!/bin/bash
# This script creates a "cronjob" using MacOSX's preferred "launchd"
# Convert minutes to seconds, then create a one-time cron that
# simply calls up a sticky growlnotify with your reminder.

# The COMMANDS_FILE is where you can customize how Reminders looks and sounds.
# You can even use a different COMMANDS_FILE if you want this to do something completely different.
# If you don't want to use bash for the COMMANDS_FILE,
# change COMMANDS_LANG to the language of your choice: /usr/bin/ruby, /usr/bin/php (etc)
COMMANDS_LANG=/bin/bash
COMMANDS_FILE="$PWD/commands.sh"

### Cleanup Script Begins ###

cleanup() {
	# get the list of plist files this user has created
	REMINDER_PLISTS=($(command ls ~/Library/LaunchAgents/com.approductive.remindersapp.*))

	# if there are plists, let's proceed to see if any are expired
	if [[ -n $REMINDER_PLISTS ]]; then

		# get list of active reminders
		ACTIVE_REMINDERS=($(launchctl list | grep com.approductive.remindersapp | awk '{print $3}'))

		# get total count of plist files to iterate
		total_plists=${#REMINDER_PLISTS[*]}
		for (( i=0; i<=$(( $total_plists -1 )); i++ ))
		do
			# remove the .plist so it will match the launchctl output for comparison
			trimmed_plist=$(basename ${REMINDER_PLISTS[$i]} | sed 's#.plist##g')
			# compare existing plist file against active launchctl list
			is_active=$(echo "${ACTIVE_REMINDERS[@]}" | grep -o "$trimmed_plist")

			# if the plist is NOT active, remove the file
			if [[ -z $is_active ]]; then
				rm ${REMINDER_PLISTS[$i]}
			fi
		done
	fi
}
### Cleanup Script Ends ###


# "cleanup" runs every time you create a reminder, but
# you can still call it manually with 'remindme cleanup'
if [[ $1 == "cleanup" ]]; then

	echo "Cleaning up expired reminders..."
	cleanup
	# exit this script if there were plist files we cleaned up or not
	exit 0

fi

# Script arguments seem to come in quoted (ie. all are within $1)
# Create array of arguments split on space
ARGUMENTS=(${1// / })

### Create Reminder Begins ###
# Format: remindme 1 the_reminder
# Format: remindme $1 $2

# Convert time to epoch
LENGTH=${ARGUMENTS[0]}

# Capture duration and unit format
DURATION=$(echo $LENGTH | perl -pe 's/(\d+)(\w+)?/$1/')
UNITS=$(echo $LENGTH | perl -pe 's/(\d+)(\w+)?/$2/')

case $UNITS in
	[hH] | [hH][rR] | [hH][oO][uU][rR])
		UNIT="hour"
		MULTI=360
		;;
	*)
		UNIT="minute"
		MULTI=60
		;;
esac

TIMER=$(($DURATION * $MULTI))
TIMESTAMP=$(command date +%s)

# Capture all remaining arguments as $REMINDER
REMINDER=${ARGUMENTS[@]:1}

echo "$DURATION $UNIT reminder:"
echo "$REMINDER"

# Insert the reminder as a plist file
cat > ~/Library/LaunchAgents/com.approductive.remindersapp.$TIMESTAMP.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.approductive.remindersapp.$TIMESTAMP</string>
	<key>ProgramArguments</key>
	<array>
		<string>$COMMANDS_LANG</string>
		<string>$COMMANDS_FILE</string>
		<string>$PWD</string>
		<string>$REMINDER</string>
	</array>
	<key>StartInterval</key>
	<integer>$TIMER</integer>
	<key>RunAtLoad</key>
	<false/>
	<key>LaunchOnlyOnce</key>
	<true/>
</dict>
</plist>
EOF

# Set permissions, then load into launchd using launchctl
chmod 644 ~/Library/LaunchAgents/com.approductive.remindersapp.$TIMESTAMP.plist
launchctl load ~/Library/LaunchAgents/com.approductive.remindersapp.$TIMESTAMP.plist

### Create Reminder Ends ###

# Run Cleanup each time
cleanup
