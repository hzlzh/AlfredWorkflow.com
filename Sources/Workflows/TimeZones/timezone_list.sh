source includes.sh

search="$1"	#Alfred argument

#Populate Alfred results with Timezones list
echo '<?xml version="1.0"?>
	<items>'

while IFS= read -r line
	do
	OIFS=$IFS
	IFS='|'		#Split stored line by delimiter
	data=($line)	#Create array
	city="${data[0]}"
	tzoffset="${data[1]/UTC/}"	#Just get the number.
	tzoffset="${tzoffset/+/}"	#Remove '+' from positive values (bc doesn't like it)
	IFS=$OIFS
	secs_offset=$(echo "$tzoffset*3600" | bc )	#Calculate offset in seconds
	if [[ $secs_offset == *.0 ]]; then		#Remove extraneous decimal fraction from bc
		secs_offset=${secs_offset%??}
	fi
	if [ $secs_offset -ge 0 ]; then		#Add or subtract offset from UTC (in Unix epoch seconds)
		city_epochtime=$(date -v "+$secs_offset"S +%s)	
	else
		city_epochtime=$(date -v "$secs_offset"S +%s) 
	fi
	city_time=$(date -u -j -f %s $city_epochtime +"%_I:%M %p") #Create readable time expression
	city_date=$(date -u -j -f %s $city_epochtime +"%A %e %B %Y") #Create readable date expression
	if [[ "$city" == "$search"* ]]; then
		echo '<item uid="'$city'" arg="'$city'|'$city_time'|'$city_date'" valid="yes">
		<title>'$city: $city_time'</title>
		<subtitle>on '$city_date'</subtitle>
		<icon>icon.png</icon>
		</item>'
	fi
	done < "$timezone_file"
echo '</items>'

IFS=$OLD_IFS
exit