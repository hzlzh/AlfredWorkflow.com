# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

##RECENT TIMERS

timerfile="$1"		

#Extract info from txt file
OLD_IFS=$IFS
IFS=$'\n'
timer_lines=( $(cat "$timerfile") )
item=${timer_lines[1]}
mins=${timer_lines[4]}
due=${timer_lines[3]}
type=${timer_lines[5]}
alarm_repeat=${timer_lines[6]}

#Pluralization of "minute" 
if [ $mins = 1 ]; then
	displaymins=minute
else
	displaymins=minutes
fi
		
#For normal timers
if [ $type = normal ]; then
	
	#Calculate Due time in Epoch seconds
	epochdue=$(date -v +$(echo $mins)M +%s)

	#Spawn the timer
	./scripts/timer.sh "$epochdue $mins $item"  > /dev/null 2>&1 &
	
	#remove the old txt file.
	rm -f $timerfile
	
	#Send notification
	echo -n "Reminder in $mins $displaymins:"$'\n'"\"$item\""
	exit
fi

#For autotimers
if [ $type = auto ]; then
		
	#Calculate Due time in Epoch seconds
	epochdue=$(date -v +$(echo $mins)M +%s) 

	#Spawn the timer
	./scripts/timer_auto.sh "$epochdue $mins $item"  > /dev/null 2>&1 &
	
	#remove the old txt file.
	rm -f $timerfile
	
	#Send notification
	echo -n "Auto-Reminder every $mins $displaymins:"$'\n'"\"$item\""
	exit
fi

#For alarms
if [ $type = alarm ]; then
	
	#Calculate EPOCH time for due time
	alarmsecs=$(date -j -f "%I:%M%p" "$due" +%s)
	nowsecs=$(date +%s)
	diff=$((alarmsecs-nowsecs))
	if [ $diff -lt 0 ]; then
		#must be tomorrow
		tomorrow=$(date -v +1d +%Y-%m-%d)
		alarmsecs=$(date -j -f "%Y-%m-%d-%I:%M%p" "$tomorrow-$due" +%s)
		#diff=$((alarmsecs-nowsecs))
	fi
	
	#Spawn the alarm
	./scripts/timer_alarm.sh "$alarmsecs $due $item $alarm_repeat"  > /dev/null 2>&1 &

	#remove the old txt file.
	rm -f "$timerfile"	

	#Send notification
	if [ $alarm_repeat ]; then
		rptmsg="(repeats $alarm_repeat)"
	fi
	echo -n "Alarm set for $due:"$'\n'"\"$item\" $rptmsg"
fi
exit