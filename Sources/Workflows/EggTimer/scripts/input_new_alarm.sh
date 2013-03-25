# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

#Working directories
EGGPREFS="$HOME/Library/Application Support/Alfred 2/Workflow Data/carlosnz.eggtimer2"
EGGWD="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/carlosnz.eggtimer2"

boilerplate='<?xml version="1.0"?>
<items>
<item uid="alarm" arg="" valid="no">
	<title>New Alarm</title>
	<subtitle>Syntax: "alarm TIME(am/pm/24hr) REMINDER"</subtitle>
	<icon>resources/icon_alarm.png</icon>
 </item> </items>'

input=($1)	#parse input into array

time=${input[0]}

#If no time info yet
if [ -z $time ]; then
	echo $boilerplate
	exit
fi

#Check if am/pm entered
if [[ ${input[0]} = *pm ]] || [[ ${input[0]} = *p.m. ]]; then
	ampm=pm
fi
if [[ ${input[0]} = *am ]] || [[ ${input[0]} = *a.m. ]]; then
	ampm=am
fi

#Strip non-digits from time
time=$(echo ${time//[!0-9]/})

#Test for XXam/pm (ie. no mins specified)
if [ ${#time} -lt 3 -a ${#time} -gt 0 ]; then
	if [ $time = 12 ]; then
		time=0
	fi
	if [ $time -lt 13 ]; then
		if [ $ampm = pm ]; then
			hour=$(($time+12))
			mins=0
			timeset=1
		fi
		if [ $ampm = am ]; then
			hour=$time
			mins=0
			timeset=1
		fi
	fi
fi

#check time is valid
if [ -z $timeset ]; then	#only if the time isn't already set from above
	if [ ${#time} -lt 3 -o ${#time} -gt 4 ]; then
		echo $boilerplate
		exit 	#too short or too long
	fi
	
	mins=${time: -2}
	hour=$(echo $time | cut -c 1-$((${#time}-2)))
	
	#test for pm
	if [ $ampm = pm ]; then
		hour=$(($hour+12))
	fi
	
	if [ $ampm = am ]; then
		if [ $hour = 12 ]; then
			hour=0
		fi
	fi
	
	if [ $hour = 24 ]; then 	#Not totally sure I need this - test it
		hour=12
	fi
		
	if [ $hour -gt 23 -o $mins -gt 60 ]; then
		echo $boilerplate
		exit	#time invalid
	fi
fi

#Calculate EPOCH time for due time
alarmsecs=$(date -j -f "%H-%M-%S" "$hour-$mins-0" +%s)
nowsecs=$(date +%s)
diff=$((alarmsecs-nowsecs))
if [ $diff -lt 0 ]; then
	#must be tomorrow
	tomorrow=$(date -v +1d +%Y-%m-%d)
	alarmsecs=$(date -j -f "%Y-%m-%d-%H-%M-%S" "$tomorrow-$hour-$mins-0" +%s)
	diff=$((alarmsecs-nowsecs))
fi

#Calculate due time in readable form
duetime=$(date -j -f %s $alarmsecs +%I:%M%p)

#Get timer name detail
item=${input[@]:1:$((${#input[@]}-1))}

icon=resources/icon_alarm.png

#Check if there is repeat info present
if [[ $item = daily* ]]; then
	rptmsg="every day "
	repeat="daily"
	item=${input[@]:2:$((${#input[@]}-1))}
	icon=resources/icon_alarm_loop.png
fi
if [[ $item = hourly* ]]; then
	rptmsg="every hour starting "
	repeat="hourly"
	item=${input[@]:2:$((${#input[@]}-1))}
	icon=resources/icon_alarm_loop.png
fi

#Display into in Alfred results
if [ -z $item ]; then
	item="EggTimer Alarm"
fi
echo '<?xml version="1.0"?>
	<items>
	<item uid="newalarm" arg="'$alarmsecs $repeat $item'">
		<title>New Alarm</title>
		<subtitle>'\"$item\" $rptmsg at $duetime'</subtitle>
		<icon>'$icon'</icon>
	 </item> </items>'
exit