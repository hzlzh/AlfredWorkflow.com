source includes.sh

city="$1"
city_string="${city// /+}"

result="$(curl --connect-timeout 20 -s "http://api.wolframalpha.com/v2/query?input=$city_string+timezone&appid=E57XK3-R9JRW6EYY8&format=plaintext")"

#echo "$result" > ~/Desktop/result.xml 	#For debugging-uncomment to see full API result on Desktop

if [[ "$result" = *"<queryresult success='true'"* ]]; then
	timezone=$(echo "$result" | grep "UTC")	#Get relevant line only
	if [ -z $timezone ]; then
		echo "Sorry. There was a problem trying to add \"$city\" to your TimeZone list."
		exit	
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
	echo "$city|$timezone" >> "$timezone_file"	#Save it to file
	echo -n "$city has been added to your list. Timezone: $timezone"
else
	echo "Sorry. There was a problem trying to add \"$city\" to your TimeZone list."
	#exit
fi
