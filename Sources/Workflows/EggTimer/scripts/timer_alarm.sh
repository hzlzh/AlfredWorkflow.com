# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

#Notification Function
source ./scripts/notify_functions.sh

input=($1)

epochdue=${input[0]}
duetime=${input[1]}
item=${input[@]:2:$((${#input[@]}-1))}

#Check for repeating
if [[ $item = *daily ]]; then
	repeat=daily
	item=${item/ daily/}
fi

if [[ $item = *hourly ]]; then
	repeat=hourly
	item=${item/ hourly/}
fi

#Create txt file for timer info
filestring=$(echo $item | sed -e 's/[^A-Za-z0-9_-]/_/g' | cut -c-20) #limits filename to sensible characters and length

echo $$ > "$EGGWD/running_alarms/timer-$filestring.tim"
echo $item >> "$EGGWD/running_alarms/timer-$filestring.tim"
echo $epochdue >> "$EGGWD/running_alarms/timer-$filestring.tim"
echo $duetime >> "$EGGWD/running_alarms/timer-$filestring.tim"
echo N/A >> "$EGGWD/running_alarms/timer-$filestring.tim"
echo alarm >> "$EGGWD/running_alarms/timer-$filestring.tim"
if [ $repeat ]; then
	echo $repeat >> "$EGGWD/running_alarms/timer-$filestring.tim"
fi

#The actual timer (at long last!)
while [ $(date +%s) -lt $epochdue ]
#Graduated sleeping dependent on how close it is to duetime, to preserve CPU usage.
do
	diff=$(($epochdue-$(date +%s)))
	if [ $diff -le 60 ]; then
		snore=0.5
	fi
	if [ $diff -gt 60 -a $diff -le 300 ]; then
		snore=1
	fi
	if [ $diff -gt 300 -a $diff -le 900 ]; then
		snore=5
	fi
	if [ $diff -gt 900 -a $diff -le 3600 ]; then
		snore=10
	fi
	if [ $diff -gt 3600 ]; then
		snore=20
	fi
	sleep $snore	
done

#sleep $secs

#Once timer elapses...

#Remove txt file
if [ $repeat ]; then
	rm -f "$EGGWD/running_alarms/timer-$filestring.tim"
else
	rm -f "$EGGWD"/last_completed_alarm/*
	cp "$EGGWD/running_alarms/timer-$filestring.tim" "$EGGWD/recent_timers"
	mv "$EGGWD/running_alarms/timer-$filestring.tim" "$EGGWD/last_completed_alarm"
fi

#Alert the user
if [ -z $repeat ]; then
	notify "Alarm Completed" "EggTimer Alarm" "✓  $item" "It's $duetime" "alarm"
	#growlnotify "It's $duetime"$'\n'$'\n'"✓  $item"$'\n' -s
	afplay sounds/alarm_done.mp3 &
else
	notify "Alarm Completed" "EggTimer Alarm" "✓  $item" "It's $duetime (repeats $repeat)" "alarm"
	#growlnotify "It's $duetime"$'\n'$'\n'"✓  $item"$'\n'"(Alarm repeats $repeat)" -s
	afplay sounds/alarm_done.mp3 &
	#Restart the alarm:
	if [ $repeat = hourly ]; then
		epochdue=$((epochdue+3600))
	else #must be daily
		epochdue=$((epochdue+86400))	
	fi
	duetime=$(date -j -f %s $epochdue +%I:%M%p)
	./scripts/timer_alarm.sh "$epochdue $duetime $item $repeat"  > /dev/null 2>&1 &
fi