# -----------------------------------------
# EggTimer 2 for Alfred 2
# by Carl Smith (@CarlosNZ)
# -----------------------------------------

#Load standard constants
source ./scripts/includes.sh

x="$1"
input=($1)	#parse Alfred {query} into "input" array

#NEW AUTO-TIMER
if [[ "every" = $x* ]]; then
	echo '<?xml version="1.0"?>
	<items>
	<item uid="auto" arg="" valid="no" autocomplete="every ">
		<title>New Auto-repeating timer?</title>
		<subtitle>Syntax: "timer every MINUTES REMINDER"</subtitle>
		<icon>resources/icon_loop.png</icon>
	 </item></items>'
	exit
fi
if [ ${input[0]} = every ]; then
	if [ -z ${input[1]} ]; then
		echo '<?xml version="1.0"?>
		<items>
		<item uid="auto" arg="" valid="no">
			<title>New Auto-repeating timer?</title>
			<subtitle>Syntax: "timer every MINUTES REMINDER"</subtitle>
			<icon>resources/icon_loop.png</icon>
		 </item></items>'
		exit
	fi
	if [[ ! ${input[1]} =~ ^[0-9,:]+$ ]]; then
		echo '<?xml version="1.0"?>
		<items>
		<item uid="error" arg="" valid="no">
			<title>Oops!</title>
			<subtitle>Incorrect syntax. Use "timer every MINS REMINDER"</subtitle>
			<icon>resources/icon_loop.png</icon>
		 </item></items>'
		exit
	else
		./scripts/input_new_auto.sh "$x"
		exit	
	fi
fi

#HELP
if [[ help = $x* ]]; then
	echo '<?xml version="1.0"?>
			<items>
			<item uid="help" arg="help">
				<title>EggTimer Help?</title>
				<subtitle>Press [Enter] to display documentation.</subtitle>
				<icon>icon.png</icon>
			 </item></items>'
	exit
fi

#ABOUT
if [[ about = $x* ]] || [[ version = $x* ]]; then
	echo '<?xml version="1.0"?>
			<items>
			<item uid="about" arg="about">
				<title>EggTimer for Alfred</title>
				<subtitle>by Carl Smith (@CarlosNZ). Version '$version'.</subtitle>
				<icon>icon.png</icon>
			 </item></items>'
	exit
fi

#CHANGELOG
if [[ change = $x* ]]; then
	echo '<?xml version="1.0"?>
			<items>
			<item uid="change" arg="change">
				<title>EggTimer for Alfred v'$version'</title>
				<subtitle>Press Enter to display changelog.</subtitle>
				<icon>icon.png</icon>
			 </item></items>'
	exit
fi

#RESET TIMERS
if [[ reset = $x* ]]; then
	if [ $x = reset ]; then
		echo '<?xml version="1.0"?>
				<items>
				<item uid="reset" arg="RESET">
					<title>Reset all timers?</title>
					<subtitle>Are you sure? This will cancel all currently running timers.</subtitle>
					<icon>icon.png</icon>
				 </item></items>'
		exit
	else
		echo '<?xml version="1.0"?>
					<items>
					<item uid="reset" arg="">
						<title>EggTimer</title>
						<subtitle>Are you sure you know what you'\''re doing?</subtitle>
						<icon>icon.png</icon>
					 </item></items>'
		exit
	fi
fi

#NUKE IT
if [[ nuke = $x* ]]; then
	if [ $x = nuke ]; then
		echo '<?xml version="1.0"?>
				<items>
				<item uid="init" arg="INIT">
					<title>Nuke it??</title>
					<subtitle>Seriously? Well, don'\''t say you weren'\''t warned. Here goes...</subtitle>
					<icon>resources/icon_nuke.png</icon>
				 </item></items>'
		exit
	else
		if [ $x = n ]; then
			echo '<?xml version="1.0"?>
						<items>
						<item uid="init" arg="">
							<title>EggTimer</title>
							<subtitle>Careful now. I hope you know what you'\''re doing...</subtitle>
							<icon>icon.png</icon>
						 </item></items>'
			exit
		fi		
		if [ $x = nu ]; then
			echo '<?xml version="1.0"?>
						<items>
						<item uid="init" arg="">
							<title>. . . ?</title>
							<subtitle> Just what do you think you'\''re doing, Dave?</subtitle>
							<icon>resources/icon_hal.png</icon>
						 </item></items>'
			exit
		fi
		if [ $x = nuk ]; then
			echo '<?xml version="1.0"?>
						<items>
						<item uid="init" arg="">
							<title>What the?!!</title>
							<subtitle>She'\''s gonna blow, Cap'\''n!!!!!</subtitle>
							<icon>resources/icon_wtf.jpg</icon>
						 </item></items>'
			exit
		fi
	fi
fi

##INSTALL OPTION
# Installs ML Notifier, notes whether it already exists or not (for later)

##UNINSTALL OPTION
# Removes ML Notifier (if it wasn't already there), and launchd entry

#FALLBACK
echo '<?xml version="1.0"?>
	<items>
	<item uid="fallback" arg="" valid="no">
		<title>Oops!</title>
		<subtitle>Alfred doesn'\''t understand. Enter "timer help" for instructions.</subtitle>
		<icon>icon.png</icon>
	 </item></items>'
exit