source includes.sh

while IFS= read -r line
	do
	OIFS=$IFS
	IFS='|'
	data=($line)
	city="${data[0]}"
	city_string="${city// /+}"
	tzoffset="${data[1]/UTC/}"
	IFS=$OIFS
	#growlnotify "Looking up $city"
	#Lookup city on Wolfram Alpha
	result="$(curl --connect-timeout 20 -s "http://api.wolframalpha.com/v2/query?input=$city_string+timezone&appid=E57XK3-R9JRW6EYY8&format=plaintext")"
	if [[ "$result" = *"<queryresult success='true'"* ]]; then
		timezone=$(echo "$result" | grep "UTC")	#Get relevant line only
		if [ -z $timezone ]; then
			if [ -z $problem ]; then
				echo "The following cities had problems and were not updated:" > "$HOME/Desktop/TimezonesUpdate.log"
			fi
			problem=1
			echo "$city" >> "$HOME/Desktop/TimezonesUpdate.log"
			echo "$line" >> "$TZPREFS"/update_timezones.txt
			continue	
		fi
		if [[ $timezone = *"30 minutes"* ]]; then
			halfhour=yes
		fi
		if [[ $timezone = *"same time"* ]]; then
			timezone="+0"
		fi		
		timezone=${timezone/from UTC | /}	#strip beginning of line	
		timezone=${timezone/ hour*/}		#strip end of line
		timezone=${timezone/<plaintext>/}	#Exception for a few cities in the old format
		timezone=${timezone/<\/plaintext>/}	#Exception for a few cities in the old format
		timezone=${timezone// /}			#strip leftover spaces
		if [ $halfhour = yes ]; then		#add half hour
			timezone=$timezone.5
			unset halfhour
		fi
		if [[ ! $timezone = *UTC* ]]; then
			timezone=UTC$timezone 	#prefix with "UTC" if it's not in there already
		fi
		echo "$city|$timezone" >> "$TZPREFS"/update_timezones.txt	
	else
		if [ -z $problem ]; then
			echo "The following cities had problems and were not updated:" > "$HOME/Desktop/TimezonesUpdate.log"
		fi
		problem=1
		echo "$city" >> "$HOME/Desktop/TimezonesUpdate.log"
		echo "$line" >> "$TZPREFS"/update_timezones.txt
		continue
	fi
	done < "$timezone_file"

mv -f "$TZPREFS"/update_timezones.txt "$timezone_file"

if [ $problem = 1 ]; then
	echo -n "Cities updated, but problems occured. See log file on Desktop for details."
else
	echo -n "City list updated successfully."
fi

