. workflowHandler.sh

# battery
BatteryCurrentCapacity=$(ioreg -l -n AppleSmartBattery -r | grep CurrentCapacity | awk '{printf ("%i", $3)}')
if [ ${#BatteryCurrentCapacity} != 0 ]
then
	BatteryMaxCapacity=$(ioreg -l -n AppleSmartBattery -r | grep MaxCapacity | awk '{printf ("%i", $3)}')
	BatteryPercent=$(echo $BatteryCurrentCapacity $BatteryMaxCapacity | awk '{printf ("%i", $1/$2 * 100)}')
	BatterySlug=$(python -c "f='●'*($BatteryPercent/10) + '○'*(10-$BatteryPercent/10);print f")
	BatteryTitle="$BatteryPercent% $BatterySlug"
	addResult "battery2.Battery" "" "$BatteryTitle" "Laptop Battery" "macbook.png" "no" ""
fi


# trackpad
TrackpadPercent=`ioreg -c BNBTrackpadDevice | grep BatteryPercent | sed 's/[a-z,A-Z, ,|,",=]//g' | tail -1 | awk '{print $1}'`
if [ ${#TrackpadPercent} = 0 ]
then
	TrackpadTitle="Not connected"
else
	TrackpadSlug=$(python -c "f='●'*($TrackpadPercent/10) + '○'*(10-$TrackpadPercent/10);print f")
	TrackpadTitle="$TrackpadPercent% $TrackpadSlug"
fi

# mouse
MousePercent=`ioreg -c BNBMouseDevice | grep BatteryPercent | sed 's/[a-z,A-Z, ,|,",=]//g' | tail -1 | awk '{print $1}'`
if [ ${#MousePercent} = 0 ]
then
	MouseTitle="Not connected"
else
	MouseSlug=$(python -c "f='●'*($MousePercent/10) + '○'*(10-$MousePercent/10);print f")
	MouseTitle="$MousePercent% $MouseSlug"
fi

# keyboard
KeyboardPercent=`ioreg -c AppleBluetoothHIDKeyboard | grep BatteryPercent | sed 's/[a-z,A-Z, ,|,",=]//g' | tail -1 | awk '{print $1}'`
if [ ${#KeyboardPercent} = 0 ]
then
	KeyboardTitle="Not connected"
else
	KeyboardSlug=$(python -c "f='●'*($KeyboardPercent/10) + '○'*(10-$KeyboardPercent/10);print f")
	KeyboardTitle="$KeyboardPercent% $KeyboardSlug"
fi


# alfred results
# create feedback entries
# addResult "uid" "arg" "title" "subtitle" "icon" "valid" "autocomplete"
addResult "battery2.Keyboard" "" "$KeyboardTitle" "Keyboard" "keyboard.png" "no" ""
addResult "battery2.Trackpad" "" "$TrackpadTitle" "Trackpad" "trackpad.png" "no" ""
addResult "battery2.Mouse" "" "$MouseTitle" "Mouse" "mouse.png" "no" ""

getXMLResults