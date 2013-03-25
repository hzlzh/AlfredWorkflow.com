# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

#"Create New Timer" option selected
if [ $1 = newtimer ]; then
	osascript -e 'tell application "Alfred 2" to search "timer "'
	exit
fi
#"Create New Alarm" option selected
if [ $1 = newalarm ]; then
	osascript -e 'tell application "Alfred 2" to search "alarm "'
	exit
fi
#"View Recent" option selected
if [ $1 = recent ]; then
	#load workflow preferences
	prefs="$(cat info.plist | tr -d '\t\n')"
	#Yes, I know it's ugly. Feel free to suggest a better way.
	keyword=$(echo "$prefs" | grep -o  '<key>config</key><dict><key>argumenttype</key><integer>2</integer><key>escaping</key><integer>0</integer><key>keyword</key><string>.*</string><key>script</key><string>./scripts/input_recent.sh</string>')					
keyword=${keyword/<key>config<\/key><dict><key>argumenttype<\/key><integer>2<\/integer><key>escaping<\/key><integer>0<\/integer><key>keyword<\/key><string>}
keyword=${keyword/<\/string><key>script<\/key><string>.\/scripts\/input_recent.sh<\/string>}
	osascript -e "tell application \"Alfred 2\" to search \"$keyword\""
	exit
fi

####DISPLAY (Selected from list)

timerfile="$1"
OLD_IFS=$IFS
IFS=$'\n'
timer_lines=( $(cat "$timerfile") )
name="${timer_lines[1]}"
epochdue="${timer_lines[2]}"
due="${timer_lines[3]}"
mins="${timer_lines[4]}"
type="${timer_lines[5]}"
alarmrepeat="${timer_lines[6]}"


source ./scripts/time_remaining_routine.sh

if [ $type = normal ]; then
	echo -n "Timer: $name"$'\n'"Due: $due"$'\n'"$display remaining."
fi
if [ $type = auto ]; then
	echo -n "Timer: $name"$'\n'"Due: $due"$'\n'"$display until next alert."
fi	
if [ $type = alarm ]; then
	if [ -z $alarmrepeat ]; then
		echo -n "Alarm: $name"$'\n'"Due: $due"$'\n'"$display remaining."
	else
		echo -n "Alarm: $name"$'\n'"Due: $due"$'\n'"$display until next alert."
	fi
fi	
IFS=$OLD_IFS
exit