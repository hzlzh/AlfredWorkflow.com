# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

input=($1)	#parse arguments passed from input window into "input" array

genaction=${input[0]}	#the General action (eg. timer, alarm, snooze, etc.)


####NEW TIMER

if [ $genaction = new ]; then
	#Get timer info
	mins=${input[1]}
	item=${input[@]:2:$((${#input[@]}-1))}	
	
	#Check timer isn't already running
	if [ -f "$EGGWD"/running_timers/timer-$(echo $item | sed -e 's/[^A-Za-z0-9_-]/_/g' | cut -c-20).tim ]; then 
		echo "Oops! That timer is already running. Please try again."
		afplay sounds/warning.mp3	
		exit
	fi
	
	#Calculate Due time in Epoch seconds
	epochdue=$(date -v +$(echo $mins)M +%s)
	
	#Spawn the timer
	./scripts/timer.sh "$epochdue $mins $item"  > /dev/null 2>&1 &
	
	#Need to show hours?
	if [ $mins -gt 59 ]; then
	hours=$((mins/60))
	mins=$((mins%60))
	and=" and "
	fi
	#Pluralization 
	if [ $mins = 1 ]; then
		displaymins="1 minute"
	else
		displaymins="$mins minutes"
	fi
	if [ $mins = 0 ]; then
		displaymins=
		and=
	fi	
	if [ $hours ]; then
		if [ $hours = 1 ]; then
			displayhrs="1 hour"
		else
			displayhrs="$hours hours"
		fi
	fi
	
	#Send notification
	echo -n "Reminder in $displayhrs$and$displaymins:"$'\n'"\"$item\""
	exit
fi

####NEW AUTO-TIMER

if [ $genaction = newauto ]; then
	#Get timer info
	mins=${input[1]}
	item=${input[@]:2:$((${#input[@]}-1))}	
	
	#Check timer isn't already running
	if [ -f "$EGGWD"/running_autotimers/timer-$(echo $item | sed -e 's/[^A-Za-z0-9_-]/_/g' | cut -c-20).tim ]; then 
		echo "Oops! That timer is already running. Please try again."
		afplay sounds/warning.mp3	
		exit
	fi

	#Calculate Due time in Epoch seconds
	epochdue=$(date -v +$(echo $mins)M +%s) 	
	
	#Spawn the timer
	./scripts/timer_auto.sh "$epochdue $mins $item"  > /dev/null 2>&1 &
		
	#Need to show hours?
	if [ $mins -gt 59 ]; then
	hours=$((mins/60))
	mins=$((mins%60))
	and=" and "
	fi
	#Pluralization 
	if [ $mins = 1 ]; then
		displaymins="1 minute"
	else
		displaymins="$mins minutes"
	fi
	if [ $mins = 0 ]; then
		displaymins=
		and=
	fi	
	if [ $hours ]; then
		if [ $hours = 1 ]; then
			displayhrs="hour"
		else
			displayhrs="$hours hours"
		fi
	fi
	
	#Send notification
	echo -n "Auto-Reminder every $displayhrs$and$displaymins:"$'\n'"\"$item\""
	exit
fi

####HELP

if [ $genaction = help ]; then
	open docs/help.html
	echo "Documentation displayed in browser."
	exit
fi

####ABOUT

if [ $genaction = about ]; then
	echo "EggTimer v$version by @CarlosNZ"$'\n'"\"timer help\" for more info."
	exit
fi

####CHANGE

if [ $genaction = change ]; then
	open docs/changelog.html
	echo "Changelog displayed in browser"
	exit
fi


####RESET

if [ $genaction = RESET ]; then
	
	#Remove pesky OSX hidden files
	rm -f "$EGGWD"/running_timers/.DS_Store
	rm -f "$EGGWD"/running_autotimers/.DS_Store	
	rm -f "$EGGWD"/running_alarms/.DS_Store

	OLD_IFS=$IFS
	IFS=$'\n'
	
	##Kill timers
	for timer in "$EGGWD"/running_timers/*
		do
			timer_lines=( $(cat "$timer") )
			kill ${timer_lines[0]}
		done
	
	#Kill auto-timers
	for timer in "$EGGWD"/running_autotimers/*
		do
			timer_lines=( $(cat "$timer") )
			kill ${timer_lines[0]}
		done
	
	#Kill alarms
	for timer in "$EGGWD"/running_alarms/*
		do
			timer_lines=( $(cat "$timer") )
			kill ${timer_lines[0]}
		done
	
	IFS=$OLD_IFS
	
	#Remove timer detail txt files
	rm -f "$EGGWD"/last_completed_timer/*
	rm -f "$EGGWD"/running_timers/*
	rm -f "$EGGWD"/last_completed_timer/*
	rm -f "$EGGWD"/running_autotimers/*
	rm -f "$EGGWD"/last_completed_alarm/*
	rm -f "$EGGWD"/running_alarms/*
	rm -f "$EGGWD"/recent_timers/*
	
	echo "EggTimer reset. All timers closed and history cleared."
	exit
fi


####INITIALISE

if [ $genaction = INIT ]; then
	#Remove pesky OSX hidden files
	rm -f "$EGGWD"/running_timers/.DS_Store
	rm -f "$EGGWD"/running_autotimers/.DS_Store	
	rm -f "$EGGWD"/running_alarms/.DS_Store

	OLD_IFS=$IFS
	IFS=$'\n'
	
	##Kill timers
	for timer in "$EGGWD"/running_timers/*
		do
			timer_lines=( $(cat "$timer") )
			kill ${timer_lines[0]}
		done
	
	#Kill auto-timers
	for timer in "$EGGWD"/running_autotimers/*
		do
			timer_lines=( $(cat "$timer") )
			kill ${timer_lines[0]}
		done
	
	#Kill alarms
	for timer in "$EGGWD"/running_alarms/*
		do
			timer_lines=( $(cat "$timer") )
			kill ${timer_lines[0]}
		done
	
	IFS=$OLD_IFS
	
	#Remove all working folders	
	rm -f -R "$EGGWD"
	rm -f -R "$EGGPREFS"
	
	#Remove MountainNotifier working directory
	rm -f -R "$HOME/Library/Application Support/MountainNotifier"
		
	#Unload launchd entry and delete plist
	launchctl unload $HOME/Library/LaunchAgents/net.philosophicalzombie.eggtimer.plist
	rm -f "$HOME/Library/LaunchAgents/net.philosophicalzombie.eggtimer.plist"
	
	echo -n "EggTimer restored to factory configuration."
	exit
fi