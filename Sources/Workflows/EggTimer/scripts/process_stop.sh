# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

timerfile="$1"

#Get info for chosen timer (from previous script)
OLD_IFS=$IFS
IFS=$'\n'
timer_lines=( $(cat "$timerfile") )
IFS=$OLD_IFS	
kill "${timer_lines[0]}" #the ProcessID		#Kill timer process
recentfile=$(basename "${timerfile//.tim/-DNC.tim}")	#Add DNC (did not complete)
mv "$timerfile" "$EGGWD"/recent_timers/$recentfile		#Move txt info to recent timers

#Notification
echo -n "\"${timer_lines[1]}\""$'\n'"stopped."
exit

