source includes.sh

#Split previous argument
OIFS=$IFS
IFS='|'
arg=($1)
IFS=$OIFS
city="${arg[0]}"

OLD_IFS=$IFS
IFS=$'\n'
for line in $(cat "$timezone_file")
do
OIFS=$IFS
IFS='|'
data=($line)
stored_city="${data[0]}"
IFS=$OIFS
if [ ! "$city" = "$stored_city" ]; then
	echo "$line" >> "$TZPREFS/newtimezones.txt"
fi
done 
IFS=$OLD_IFS

mv -f "$TZPREFS/newtimezones.txt" "$timezone_file"

echo -n "$city has been removed from your TimeZone list."