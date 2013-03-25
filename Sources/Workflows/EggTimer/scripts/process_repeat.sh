# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

input=($1)	#parse arguments passed from input window into "input" array
mins=${input[0]}
timerfile=${input[@]:1:$((${#input[@]}-1))}	

####REPEAT TIMER
	
OLD_IFS=$IFS
IFS=$'\n'
timer_lines=( $(cat "$timerfile") )
IFS=$OLD_IFS
item=${timer_lines[1]}

#Pluralization of "minute" 
if [ $mins = 1 ]; then
	displaymins=minute
else
	displaymins=minutes
fi

#Calculate Due time in Epoch seconds
epochdue=$(date -v +$(echo $mins)M +%s)

#Spawn the timer
./scripts/timer.sh "$epochdue $mins $item"  > /dev/null 2>&1 &

#remove the old txt file.
rm -f "$timerfile"

#Send notification
echo -n "Reminder in $mins $displaymins:"$'\n'"\"$item\""
exit