# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh


####SET SNOOZE VALUE

input=($1)
if [ ${input[0]} = setsnooze ];then  #We're setting it, not snoozing it
	snoozemins=${input[1]}
	#Replace snooze time in txt file.
	echo $snoozemins > "$EGGPREFS"/snoozetimer.txt
	#Pluralization of "minute" 
	if [ $snoozemins = 1 ]; then
		displaymins=minute
	else
		displaymins=minutes
	fi
	
	#Notification
	echo -n "The snooze time is now set for $snoozemins $displaymins."
	exit
fi


####SNOOZE TIMER

#Get stored snooze info
snoozemins=$(cat "$EGGPREFS"/snoozetimer.txt)

#Get info of timer to snooze
snoozetimer="$1"
OLD_IFS=$IFS
IFS=$'\n'
snooze_timer_lines=( $(cat "$snoozetimer") )
IFS=$OLD_IFS
item=${snooze_timer_lines[1]}
type=${snooze_timer_lines[5]}

#Pluralization of "minute" 
if [ $snoozemins = 1 ]; then
	displaymins=minute
else
	displaymins=minutes
fi

#Calculate Due time in Epoch seconds
epochdue=$(date -v +$(echo $snoozemins)M +%s)

duetime=$(date -j -f %s $epochdue +%I:%M%p)

#Spawn the timer
if [ $type = alarm ]; then
	./scripts/timer_alarm.sh "$epochdue $duetime $item"  > /dev/null 2>&1 &
else
	./scripts/timer.sh "$epochdue $snoozemins $item"  > /dev/null 2>&1 &
fi

#remove the old txt file.
rm -f "$snoozetimer"

#Send notification
echo -n "\"$item\" snoozed for $snoozemins $displaymins."
exit