#Calculate remaining time
rem_secs=$((epochdue-$(date +%s)))
#More than an hour?
if [ $rem_secs -ge 3600 ]; then
	rem_hrs=$((rem_secs/3600))
	rem_secs=$((rem_secs%3600))
fi
#More than a minute?
if [ $rem_secs -ge 60 ]; then
	rem_mins=$((rem_secs/60))
	rem_secs=$((rem_secs%60))
fi
#Pluralisation and display
if [ $rem_secs = 1 ]; then
	display="$rem_secs second"
else
	display="$rem_secs seconds"
fi
if [ $rem_mins ]; then
	if [ $rem_mins = 1 ]; then
		display="$rem_mins minute and $display"
	else
		display="$rem_mins minutes and $display"
	fi
fi
if [ $rem_hrs ]; then
	if [ $rem_hrs = 1 ]; then
		display="$rem_hrs hour, $display"
	else
		display="$rem_hrs hours, $display"
	fi
fi
unset rem_hrs
unset rem_mins