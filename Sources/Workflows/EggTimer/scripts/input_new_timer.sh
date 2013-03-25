# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

input=($1)	#parse input into array

time=${input[0]}
item=${input[@]:1:$((${#input[@]}-1))}

if [[ $time = *:* ]]; then	#break it down into Hrs:Mins
	OLD_IFS=$IFS
	IFS=$':'
	timearr=($time)
	hours="${timearr[0]}"
	mins="${timearr[1]}"
	if [[ $mins = 0* ]]; then
		mins=${mins//0/}
	fi
	if [ $hours ]; then
		mins=$((hours*60+mins))
	fi
else
	mins=$time
fi

if [ $mins = 0 ]; then		#Don't allow "0" length timer
	echo '<?xml version="1.0"?>
	<items>
	<item uid="fallback" arg="" valid="no">
		<title>Welcome to EggTimer for Alfred</title>
		<subtitle>Enter "timer help" for instructions.</subtitle>
		<icon>icon.png</icon>
	 </item></items>'
	exit
fi

outputmins=$mins 	#Total minutes for sending to next script

if [ -z $item ]; then
	item="Reminder"
fi
#Display details in Alfred results
if [ ! $mins ]; then
	mins=0
fi
if [ $mins -gt 59 ]; then
	hours=$((mins/60))
	mins=$((mins%60))
	and="and "
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
		displayhrs="1 hour "
	else
		displayhrs="$hours hours "
	fi
fi
echo '<?xml version="1.0"?>
	<items>
	<item uid="newtimer" arg="new '$outputmins $item'" valid="yes">
		<title>New Timer:</title>
		<subtitle>'\"$item\"' in '$displayhrs$and$displaymins'</subtitle>
		<icon>icon.png</icon>
	 </item></items>'
exit