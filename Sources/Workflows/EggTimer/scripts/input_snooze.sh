# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh


#Get snoozeminutes
snoozemins=$(cat "$EGGPREFS"/snoozetimer.txt)
#Pluralization of "minute" 
if [ $snoozemins = 1 ]; then
	displaymins=minute
else
	displaymins=minutes
fi

#Get details for last completed timer/alarm from txt file.
rm -f "$EGGWD"/last_completed_timer/.DS_Store
rm -f "$EGGWD"/last_completed_alarm/.DS_Store
if [ ! $(ls -A "$EGGWD"/last_completed_timer) ]; then
	no_timers=1
fi
if [ ! $(ls -A "$EGGWD"/last_completed_alarm) ]; then
	no_alarms=1
fi
if [ $no_timers = 1  -a $no_alarms = 1 ]; then
	if [ -z $1 ]; then
		#If no last completed timer available...
		echo '<?xml version="1.0"?>
		<items>
		<item uid="nosnooze" arg="" valid="no">
			<title>Sorry...</title>
			<subtitle>Nothing available to snooze.</subtitle>
			<icon>resources/icon_snooze.png</icon>
		 </item>
		 <item uid="setsnooze" arg="setsnooze" valid="no" autocomplete="set ">
			<title>Set Snooze time?</title>
			<subtitle>Syntax: "snooze set MINUTES" (Currently '$snoozemins $displaymins')</subtitle>
			<icon>resources/icon_snooze.png</icon>
		 </item></items>'
		exit
	fi
fi

OLD_IFS=$IFS
IFS=$'\n'
if [ -z $no_timers ]; then
	for finished_timer in "$EGGWD"/last_completed_timer/*
		do
		fin_timer_lines=( $(cat "$finished_timer") )
		timerdue=${fin_timer_lines[2]}
		done
fi
if [ -z $no_alarms ]; then
	for finished_alarm in "$EGGWD"/last_completed_alarm/*
		do
		fin_alarm_lines=( $(cat "$finished_alarm") )
		alarmdue=${fin_alarm_lines[2]}
		done
fi
IFS=$OLD_IFS

#which is newer?
if [ -z $timerdue ]; then	#Makes variable alive to avoid error in subsequent difference test
	timerdue=1
fi
if [ -z $alarmdue ]; then
	alarmdue=1
fi
if [ $alarmdue -gt $timerdue ]; then
	#Use the alarm
	launchtimer=$finished_alarm
	item=${fin_alarm_lines[1]}
	icon=resources/icon_alarm_snooze.png
	kind=alarm
else
	#Use timer
	launchtimer=$finished_timer
	item=${fin_timer_lines[1]}
	icon=resources/icon_snooze.png
	kind=timer
fi	

#Get parameter (needed if setting snooze value)
input=($1)
set=${input[0]}
mins=${input[1]}

#Pluralization of "minute" 
if [ $mins = 1 ]; then
	displaymins=minute
else
	displaymins=minutes
fi

#Alfred output when not setting the snooze value
if [ -z $1 ]; then
	#Display details in Alfred results
	echo '<?xml version="1.0"?>
	<items>
	<item uid="snooze" arg="'$launchtimer'">
		<title>Snooze last-finished '$kind'?</title>
		<subtitle>"'$item'" - snooze for '$snoozemins' '$displaymins'</subtitle>
		<icon>'$icon'</icon>
	 </item>
	  <item uid="setsnooze" arg="setsnooze" valid="no" autocomplete="set ">
			<title>Set Snooze time?</title>
			<subtitle>Syntax: "snooze set MINUTES" (Currently '$snoozemins $displaymins')</subtitle>
			<icon>resources/icon_snooze.png</icon>
		 </item></items>'
	exit
fi

#Do we want to SET the snooze time?
if [[ set = $set* ]]; then
	if [ ! $set = set ]; then
		echo '<?xml version="1.0"?>
	<items>
	  <item uid="setsnooze" arg="setsnooze" valid="no" autocomplete="set ">
			<title>Set Snooze time?</title>
			<subtitle>Syntax: "snooze set MINUTES" (Currently '$snoozemins $displaymins')</subtitle>
			<icon>resources/icon_snooze.png</icon>
		 </item></items>'
	fi
fi

if [ $set = "set" ]; then
	if [ $mins ]; then
	#Check validity of entered minutes
		if [[ $mins =~ ^[0-9]+$ ]]; then
			echo '<?xml version="1.0"?>
				<items>
				<item uid="snooze" arg="setsnooze '$mins'">
					<title>Set snoozetime...</title>
					<subtitle>to '$mins $displaymins'</subtitle>
					<icon>resources/icon_snooze.png</icon>
				 </item></items>'			
		else
			echo '<?xml version="1.0"?>
					<items>
					<item uid="error" arg="" valid="no">
						<title>Oops!</title>
						<subtitle>Incorrect syntax. Use "snooze set MINS"</subtitle>
						<icon>resources/icon_snooze.png</icon>
					 </item></items>'
		fi
	else
		echo '<?xml version="1.0"?>
		<items>
		  <item uid="setsnooze" arg="setsnooze" valid="no" autocomplete="set ">
			<title>Set Snooze time?</title>
			<subtitle>Syntax: "snooze set MINUTES" (Currently '$snoozemins $displaymins')</subtitle>
			<icon>resources/icon_snooze.png</icon>
		 </item></items>'
	fi
fi