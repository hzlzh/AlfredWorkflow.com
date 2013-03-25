#Enable aliases for this script
shopt -s expand_aliases

#define aliases
# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

#Is there a timer to repeat?
rm -f "$EGGWD"/last_completed_timer/.DS_Store	#Delete pesky OS X hidden files
if [ ! $(ls -A "$EGGWD"/last_completed_timer) ]; then
	#If no last completed timer available...
	echo '<?xml version="1.0"?>
	<items>
	<item uid="norepeat" arg="" valid="no">
		<title>Sorry...</title>
		<subtitle>No timers available to repeat.</subtitle>
		<icon>resources/icon_snooze.png</icon>
	 </item></items>'
	exit
fi

#Extract info from timer txt file
OLD_IFS=$IFS
IFS=$'\n'
for finished_timer in "$EGGWD"/last_completed_timer/*
	do
	fin_timer_lines=( $(cat "$finished_timer") )
	name=${fin_timer_lines[1]}
	mins=${fin_timer_lines[4]}
	type=${fin_timer_lines[5]}
	if [ ! -z $1 ]; then
		mins=$1
	fi
	#Pluralization of "minute" 
	if [ $mins = 1 ]; then
		displaymins=minute
	else
		displaymins=minutes
	fi
	done
IFS=$OLD_IFS

if [ $1 ]; then
	#Is the parameter valid minutes?
	if [[ ! $1 =~ ^[0-9]+$ ]]; then
		echo '<?xml version="1.0"?>
		<items>
		<item uid="error" arg="" valid="no">
			<title>Oops!</title>
			<subtitle>Incorrect syntax. Use "repeat MINS" (minutes optional)</subtitle>
			<icon>resources/icon_snooze.png</icon>
		 </item></items>'
		exit
	fi
fi

#Display info in Alfred results
echo '<?xml version="1.0"?>
<items>
<item uid="repeat" arg="'$mins' '$finished_timer'" autocomplete="repeat">
	<title>Repeat last timer?</title>
	<subtitle>"'$name'" - '$mins' '$displaymins'</subtitle>
	<icon>resources/icon_repeat.png</icon>
 </item></items>'
exit