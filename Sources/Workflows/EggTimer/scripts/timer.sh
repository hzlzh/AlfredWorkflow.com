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
mins=${input[1]}
item=${input[@]:2:$((${#input[@]}-1))}


#Pluralization of "minute".
if [ $mins = 1 ]; then
	displaymins=minute
else
	displaymins=minutes
fi

#Calculate when timer due in H:MM am/pm format
timerdue=$(date -j -f %s $epochdue +%I:%M%p)

#Create txt file for timer info
filestring=$(echo $item | sed -e 's/[^A-Za-z0-9_-]/_/g' | cut -c-20) #limits filename to sensible characters and length



echo $$ > "$EGGWD/running_timers/timer-$filestring.tim"
echo $item >> "$EGGWD/running_timers/timer-$filestring.tim"
echo $epochdue >> "$EGGWD/running_timers/timer-$filestring.tim"
echo $timerdue >> "$EGGWD/running_timers/timer-$filestring.tim"
echo $mins >> "$EGGWD/running_timers/timer-$filestring.tim"
echo normal >> "$EGGWD/running_timers/timer-$filestring.tim"

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

#Once timer elapses...

#Remove txt file
rm -f "$EGGWD"/last_completed_timer/*
cp "$EGGWD/running_timers/timer-$filestring.tim" "$EGGWD/recent_timers"
mv "$EGGWD/running_timers/timer-$filestring.tim" "$EGGWD/last_completed_timer"

#Alert the user
notify "Timer Completed" "EggTimer" "✓  $item" "$mins $displaymins is up." "timer"
afplay sounds/alarm_done.mp3 &
