# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

input=($1)	#parse arguments passed from input window into "input" array

####NEW ALARM

epochdue=${input[0]}
item=${input[@]:1:$((${#input[@]}-1))}
#Is there "repeat" info?
if [[ $item = hourly* ]]; then
	item=${item/hourly /}
	repeat=hourly
fi
if [[ $item = daily* ]]; then
	item=${item/daily /}
	repeat=daily
fi

duetime=$(date -j -f %s $epochdue +%I:%M%p)

#Check timer isn't already running
if [ -f "$EGGWD"/running_alarms/timer-$(echo $item | sed -e 's/[^A-Za-z0-9_-]/_/g' | cut -c-20).tim ]; then 
	echo "Oops! That alarm is already running. Please try again."
	afplay sounds/warning.mp3	
	exit
fi	

#Spawn the alarm
./scripts/timer_alarm.sh "$epochdue $duetime $item $repeat"  > /dev/null 2>&1 &

#Send notification
if [ $repeat ]; then
	rptmsg="(repeats $repeat)"
fi
echo -n "Alarm set for $duetime:"$'\n'"\"$item\" $rptmsg"