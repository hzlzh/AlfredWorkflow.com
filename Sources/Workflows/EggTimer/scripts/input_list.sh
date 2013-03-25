# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

#Remove pesky hidden .DS_Store files (Is there a better way to avoid this problem?)
rm -f "$EGGWD"/running_timers/.DS_Store
rm -f "$EGGWD"/running_autotimers/.DS_Store
rm -f "$EGGWD"/running_alarms/.DS_Store

echo '<?xml version="1.0"?>
	<items>
	<item uid="newtimer" arg="newtimer" valid="yes">
		<title>New Timer</title>
		<subtitle>Create a new timer with EggTimer</subtitle>
		<icon>icon.png</icon>
	  </item>
  	<item uid="newalarm" arg="newalarm" valid="yes">
		<title>New Alarm</title>
		<subtitle>Create a new alarm with EggTimer</subtitle>
		<icon>resources/icon_alarm.png</icon>
	  </item>'
if [ "$(ls -A "$EGGWD"/recent_timers)" ]; then
	echo '<item uid="recent" arg="recent" valid="yes">
		<title>Recent Timers</title>
		<subtitle>See your recent timers and alarms</subtitle>
		<icon>icon.png</icon>
	  </item>'
fi
	


#If no timers are running...
if [ ! $(ls -A "$EGGWD"/running_timers) ]; then
	no_timers=1
fi
if [ ! $(ls -A "$EGGWD"/running_autotimers) ]; then
	no_autotimers=1
fi
if [ ! $(ls -A "$EGGWD"/running_alarms) ]; then
	no_alarms=1
fi
if [ $no_timers = 1 -a $no_autotimers = 1 -a $no_alarms = 1 ]; then
	echo ' <item uid="timer" arg="" valid="no">
				<title>No timers or alarms currently running</title>
				<subtitle>Enter "timer help" for usage instructions.</subtitle>
				<icon>icon.png</icon>
			  </item>
			</items>'
	exit
fi


OLD_IFS=$IFS
IFS=$'\n'
	 
#Build status output details for regular timers
if [ -z $no_timers ]; then
	for timer in "$EGGWD"/running_timers/*
		do
			timer_lines=( $(cat "$timer") )
			#Check if timer's bash processID still exists, and resurrect if not.
			timer_status=$(ps -o etime= -p ${timer_lines[0]})
			if [ ! $timer_status ]; then	
				./scripts/timer_resurrect.sh "$timer"
			fi				
			#Output timer details if timer is still supposed to exist
			if [ -e $timer ]; then
				#Calculate remaining time
				epochdue=${timer_lines[2]}
				source ./scripts/time_remaining_routine.sh
				echo  '  <item uid="'$RANDOM'" arg="'$timer'">
							<title>Active Timer: '${timer_lines[1]}'</title>
							<subtitle>Due: '${timer_lines[3]} \($display remaining\)'</subtitle>
							<icon>icon.png</icon>
						  </item>'
			fi
		done
fi

#Build status output details for auto-repeat timers
if [ -z $no_autotimers ]; then
	for autotimer in "$EGGWD"/running_autotimers/*
		do
			autotimer_lines=( $(cat "$autotimer") )
			#Check if timer's bash processID still exists, and resurrect if not.
			timer_status=$(ps -o etime= -p ${autotimer_lines[0]})
			if [ ! $timer_status ]; then
				./scripts/timer_resurrect.sh "$autotimer"				
			fi
			#Output timer details
			epochdue=${autotimer_lines[2]}
			source ./scripts/time_remaining_routine.sh
			echo  '  <item uid="'$RANDOM'" arg="'$autotimer'">
						<title>Active Timer: '${autotimer_lines[1]}'</title>
						<subtitle>Next Due: '${autotimer_lines[3]} \($display remaining\)' (repeats every '${autotimer_lines[4]}' minutes)</subtitle>
						<icon>resources/icon_loop.png</icon>
					  </item>'
		done
fi

#Build status output details for alarms
if [ -z $no_alarms ]; then
	for alarm in "$EGGWD"/running_alarms/*
		do
			alarm_lines=( $(cat "$alarm") )
			#Check if timer's bash processID still exists, and resurrect if not.
			timer_status=$(ps -o etime= -p ${alarm_lines[0]})
			if [ ! $timer_status ]; then
				./scripts/timer_resurrect.sh "$alarm"				
			fi
			#Output timer details if the alarm is still supposed to exist
			if [ -e $alarm ]; then
				epochdue=${alarm_lines[2]}
				source ./scripts/time_remaining_routine.sh
				if [ ${alarm_lines[6]} ]; then
					rptmsg=" (repeats ${alarm_lines[6]})"
					icon="resources/icon_alarm_loop.png"
				else
					icon="resources/icon_alarm.png"
				fi
				echo  '  <item uid="'$RANDOM'" arg="'$alarm'">
							<title>Active Alarm: '${alarm_lines[1]}'</title>
							<subtitle>Due: '${alarm_lines[3]} \($display remaining\)$rptmsg'</subtitle>
							<icon>'$icon'</icon>
						  </item>'
				rptmsg=
			fi
		done
fi
echo '</items>'

IFS=$OLD_IFS
exit