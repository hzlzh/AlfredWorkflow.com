notify () {

#What is the chosen notification method?
prefs=$(cat info.plist | tr -d '\n\t') #Load workflow's settings info
if [[ "$prefs" = *'<key>output</key><integer>0</integer>'* ]]; then
	notification=default
fi
if [[ "$prefs" = *'<key>output</key><integer>1</integer>'* ]]; then
	notification=NC
fi
if [[ "$prefs" = *'<key>output</key><integer>2</integer>'* ]]; then
	notification=growl
fi

if [ $notification = default ]; then
	notpref=$(cat ../../preferences/notifications/prefs.plist | tr -d '\n\t') 
	if [[ "$notpref" = *'<key>defaultoutput</key><integer>1</integer>'* ]]; then
		notification=growl
	else
		notification=NC
	fi
fi

if [ "$5" = alarm ]; then
	growl_icon="$PWD/resources/icon_alarm.png"
	nc_icon="$PWD/resources/icon_alarm.icns"
	dummy_app="EggTimer Alarm"
else
	growl_icon="$PWD/icon.png"
	nc_icon="$PWD/resources/icon.icns"
	dummy_app="EggTimer"
fi

if [ $notification = growl ]; then
	osascript <<EOD
	set imgfd to open for access POSIX file "$growl_icon"
	set img to read imgfd as "TIFF"
	close access imgfd
	tell application id "com.Growl.GrowlHelperApp"
	notify with name "$1" title "$2" description "$3\n$4" application name "EggTimer for Alfred" sticky "true" image img
	end tell
EOD
fi

if [ $notification = NC ]; then
	./MountainNotifier/MountainNotifier "$dummy_app" "$2" "$3" "$4" "$nc_icon"
fi
}