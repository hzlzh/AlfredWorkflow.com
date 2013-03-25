# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

#Notification Function
source ./scripts/notify_functions.sh

#script_dir=$(dirname "$0") #Needed for when running script from other system processes.

#What is the chosen notification method?
prefs=$(cat info.plist | tr -d '\n\t') #Load workflow's settings info
if [[ "$prefs" = *'<key>output</key><integer>0</integer>'* ]]; then
	notification=default
fi
if [[ "$prefs" = *'<key>output</key><integer>1</integer>'* ]]; then
	notification=NC
fi
if [[ "$prefs" = *'<key>output</key><integer>2</integer>'* ]]; then
	notification=growl
fi

if [ $notification = default ]; then
	notpref=$(cat ../../preferences/notifications/prefs.plist | tr -d '\n\t') 
	if [[ "$notpref" = *'<key>defaultoutput</key><integer>1</integer>'* ]]; then
		notification=growl
	else
		notification=NC
	fi
fi

deadtimer="$1"

OLD_IFS=$IFS
IFS=$'\n'

#Get info for dead timer
timer_lines=($(cat "$deadtimer"))
item="${timer_lines[1]}"
epochdue="${timer_lines[2]}"
duetime="${timer_lines[3]}"
mins="${timer_lines[4]}"
type="${timer_lines[5]}"
alarm_repeat="${timer_lines[6]}"


##Normal Timers
if [ $type = normal ]; then
	#Is it overdue?
	if [ $epochdue -lt $(date +%s) ]; then
		#growlnotify "Better late than never. Timer \"$item\" was due at $duetime. Sorry." -s
		notify "Timer Completed" "EggTimer" "Better late than never." "Timer \"$item\" was due at $duetime. Sorry." "timer"
		rm -f "$EGGWD"/last_completed_timer/*
		cp $deadtimer "$EGGWD"/recent_timers
		mv $deadtimer "$EGGWD"/last_completed_timer
		exit
	else  #Restart it
		./scripts/timer.sh "$epochdue $mins $item"  > /dev/null 2>&1 &
		#growlnotify "Timer resurrected:"$'\n'"\"$item\""$'\n'"Due at $duetime." -s
	fi
exit
fi

##Auto Timers
if [ $type = auto ]; then
	#Is it overdue?
	if [ $epochdue -lt $(date +%s) ]; then
		#When's it next due?
		secs=$((mins*60))
		while [ $epochdue -lt $(date +%s) ]
		do
			epochdue=$((epochdue+secs))
		done
	fi
	#Restart it
	duetime=$(date -j -f %s $epochdue +%I:%M%p)	#New duetime
	./scripts/timer_auto.sh "$epochdue $mins $item"  > /dev/null 2>&1 &
	#growlnotify "Auto-timer resurrected:"$'\n'"\"$item\""$'\n'"Next due at $duetime." -s
exit
fi

##Alarms
#Standard alarms
if [ $type = alarm ] && [ -z $alarm_repeat ]; then
	#Is it overdue?
	if [ $epochdue -lt $(date +%s) ]; then
		#growlnotify "Better late than never. Alarm \"$item\" was due at $duetime. Sorry." -s
		notify "Alarm Completed" "EggTimer" "Better late than never." "Alarm \"$item\" was due at $duetime. Sorry." "alarm"
		rm -f "$EGGWD"/last_completed_alarm/*
		cp $deadtimer "$EGGWD"/recent_timers
		mv $deadtimer "$EGGWD"/last_completed_alarm
		exit
	else	#Restart it
		./scripts/timer_alarm.sh "$epochdue $duetime $item"  > /dev/null 2>&1 &
		#growlnotify "Alarm resurrected:"$'\n'"\"$item\""$'\n'"Due at $duetime." -s
	fi
	exit
fi

#Repeating Alarms
if [ $type = alarm ] && [ $alarm_repeat ]; then
	#Is it overdue?
	if [ $epochdue -lt $(date +%s) ]; then
		#When's it next due
		if [ $alarm_repeat = hourly ]; then
			secs=3600
		else	#must be daily
			secs=86400
		fi
		while [ $epochdue -lt $(date +%s) ]
		do
			epochdue=$((epochdue+secs))
		done
	fi
	#Restart it
	duetime=$(date -j -f %s $epochdue +%I:%M%p)	#New duetime
	./scripts/timer_alarm.sh "$epochdue $duetime $item $alarm_repeat"  > /dev/null 2>&1 &
	#growlnotify "Alarm resurrected:"$'\n'"\"$item\""$'\n'"Next due at $duetime." -s
	exit
fi

IFS=$OLD_IFS
exit