# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh


#Remove pesky hidden .DS_Store files (Is there a better way to avoid this problem?)
rm -f "$EGGWD"/recent_timers/.DS_Store

#If no timers are present...
if [ ! $(ls -A "$EGGWD"/recent_timers) ]; then
	echo '<?xml version="1.0"?>
			<items>
			  <item uid="recent" arg="" valid="no">
				<title>EggTimer</title>
				<subtitle>No recent timers. Enter "timer help" for usage instructions.</subtitle>
				<icon>icon.png</icon>
			  </item>
			</items>'
	exit
fi

## If more than 10 recent timers, delete the older ones.
if [ $(echo $(find "$EGGWD"/recent_timers -type f | wc -l)) -gt 10 ]; then
	count=1
	for timers in $(echo $(ls -t "$EGGWD"/recent_timers/))
		do
		if [ $count -gt 10 ]; then
			rm -f "$EGGWD"/recent_timers/$timers
		fi
		let count++
		done
fi

OLD_IFS=$IFS
IFS=$'\n'

#Display details in Alfred results
echo '<?xml version="1.0"?>
	<items>'

for timer in "$EGGWD"/recent_timers/*
			do
				timer_lines=( $(cat "$timer") )
				item=${timer_lines[1]}
				epochdue=${timer_lines[2]}
				due=${timer_lines[3]}
				mins=${timer_lines[4]}
				type=${timer_lines[5]}
				alarmrepeat=${timer_lines[6]}
				
				#Last alert time, nicely formatted
				if [[ $timer = *-DNC.tim ]]; then
					last="did not complete"
					lastformat=1
				fi
				if [ -z $lastformat ]; then
					if [ $(date +%F) = $(date -j -f %s $epochdue +%F) ]; then
						last=today
						lastformat=1
					fi
					if [ $(echo "$(date +%j)-$(date -j -f %s $epochdue +%j)" | bc) = 1 ]; then
						last=yesterday
						lastformat=1
					fi
				fi
				if [ -z $lastformat ]; then
					if [ $(echo "$(date +%j)-$(date -j -f %s $epochdue +%j)" | bc) -lt 7 -a $(date +%Y) = $(date -j -f %s $epochdue +%Y) ]; then
						last="on $(date -j -f %s $epochdue +%A)"
						lastformat=1
					fi
				fi
				if [ -z $lastformat ]; then
					if [ $(date +%Y) = $(date -j -f %s $epochdue +%Y) ]; then
						last="on $(date -j -f %s $epochdue +"%a %d %b")"
					else
						last="on $(date -j -f %s $epochdue +"%a %d %b %Y")"
					fi
				fi
				unset lastformat
				#echo "$item -- $last" >> ~/Desktop/test.txt
								
				#if normal
				if [ $type = normal -o $type = auto ]; then
					if [ $type = auto ]; then
						rptmsg="(auto-repeating)"
						icon=resources/icon_loop.png
					else
						icon=icon.png
					fi
					#Nice time display
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
					if [ $last = "did not complete" ]; then
						lastdisplay="(Last run did not complete)"
					else
						lastdisplay="(Last alert at $(date -j -f %s $epochdue +"%I:%M %p") $last)"
					fi
					
					echo '<item uid="'$timer'" arg="'$timer'">
						<title>Timer: '$item'</title>
						<subtitle>'$displayhrs$and$displaymins $rptmsg $lastdisplay'</subtitle>
						<icon>'$icon'</icon>
					  </item>'
					rptmsg=
					hours=
					displayhrs=
					and=
					mins=
				else #must be alarm then
					if [ $alarmrepeat ]; then
						rptmsg="(then repeats $alarmrepeat)"
					fi
					echo  '<item uid="'$timer'" arg="'$timer'">
							<title>Alarm: '$item'</title>
							<subtitle>'$due $rptmsg \(Last alarm $last\)'</subtitle>
							<icon>resources/icon_alarm.png</icon>
						  </item>'
					rptmsg=
				fi
			done
echo '</items>'

IFS=$OLD_IFS
exit