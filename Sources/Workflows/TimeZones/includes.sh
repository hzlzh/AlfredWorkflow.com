#includes for TimeZones scripts

#Working Directories
TZWD="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/carlosnz.timezones"
TZPREFS="$HOME/Library/Application Support/Alfred 2/Workflow Data/carlosnz.timezones"

#Enable aliases for this script
shopt -s expand_aliases

#Case-insensitive matching
shopt -s nocasematch

#define aliases
alias growlnotify='/usr/local/bin/growlnotify EggTimer --image icon.png -m '

#First run check
if [ ! -e "$TZPREFS/config" ]; then
	mkdir "$TZPREFS"
	cp default_timezones.txt "$TZPREFS/timezones.txt"
	echo "$TZPREFS/timezones.txt" > "$TZPREFS/config"
fi

#Load path to the user's timezones.txt file.
timezone_file=$(cat "$TZPREFS/config")

#Does the file actually exist?
if [ ! -e "$timezone_file" ]; then
	#If not, recreate it from defaults
	cp default_timezones.txt "$TZPREFS/timezones.txt"
	echo "$TZPREFS/timezones.txt" > "$TZPREFS/config"
	timezone_file=$(cat "$TZPREFS/config")
fi