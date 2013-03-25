version="2.0"

#Enable aliases for this script
shopt -s expand_aliases

#define aliases
alias growlnotify='/usr/local/bin/growlnotify EggTimer --image icon.png -m '

#Working directories
EGGPREFS="$HOME/Library/Application Support/Alfred 2/Workflow Data/carlosnz.eggtimer2"
EGGWD="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/carlosnz.eggtimer2"

wfdir=$PWD		#Get workflow directory