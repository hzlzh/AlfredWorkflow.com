#!/bin/bash

function installApplication {
    APPLICATION=$1
    APP_NAME=`basename ${APPLICATION}`
    APP_EXTENSION=${APPLICATION##*.}

    case $APP_EXTENSION in
	app)
	    if [ "${APPLICATION}" = "/Applications/${APP_NAME}" ];then
		echo "'${APP_NAME}' has already been installed. No need to continue."
	    else
		osascript >& /dev/null <<-EOF
					tell application "Finder"
						try
							move POSIX file "${APPLICATION}" to folder "Applications" of startup disk with replacing
						on error errMsg number errNr
							if errNr is -8087 then
								tell application "System Events" to display dialog "Unable to install application ${APP_NAME}.\n\nIt looks like you're trying to update an application that is still running." buttons "OK" with title "Alfred Install Action" with icon caution
							else
								tell application "System Events" to display dialog "Unable to install application.\n\n" & errMsg buttons "OK" with title "Alfred Install Action" with icon caution
							end if
							error errMsg number errNr
						end try
					end tell
				EOF

		if [ $? -ne 0 ];then
		    echo "Application '${APP_NAME}' not installed."
		else
		    echo "Application '${APP_NAME}' sucessfully installed."
		fi
	    fi
	    ;;
	pkg|mpkg)
	    osascript >& /dev/null <<-EOF
				tell application "Finder"
					open POSIX file "${APPLICATION}"
				end tell
			EOF

	    # Find the latest installer process in case others are running already
	    PID=`ps -A -o pid,etime,command | sort -k2 | grep -i "/Installer.app" | grep -v "grep" | head -n1 | awk '{print $1}'`

	    # Wait for the process to end. Can't do this with wait since it's not a sub process of this shell
	    if [ "$PID" ]; then
		while kill -0 "$PID" 2> /dev/null; do
		    sleep 2
		done
	    fi

	    echo "Installation process of '${APP_NAME}' completed."
	    ;;
	alfredextension|prefPane)
	    osascript >& /dev/null <<-EOF
				tell application "Finder"
					open POSIX file "${APPLICATION}"
				end tell
			EOF
			echo "Installation process of '${APP_NAME}' started. Complete manually."
			;;
	*)
	    echo "Unsupported applicationtype."
	    ;;
    esac
}

function installSoftware {
    FILENAME="$1"
    EXTENSION=${FILENAME##*.}

    #LATEST_CTIME=`find /Applications -type d -name "*.app" -prune -ctime -15 -exec stat -f "%c" {} \; | sort -rn | head -n 4 | tail -n 1`
    LATEST_CTIME=`find /Applications -type d -name "*.app" -prune -ctime -15 -exec stat -f "%c" {} \; | sort -rn | head -n 1`

    case $EXTENSION in
	dmg)
	    MOUNTPOINT=`echo "Y" | hdiutil attach -noautoopen -nobrowse -puppetstrings "${FILENAME}" | grep "/Volumes/" | sed -e 's#.*\(/Volumes/.*\)#\1#'`
	    APPLICATIONS=`find "${MOUNTPOINT}" -not -path "${MOUNTPOINT}" 2> /dev/null | grep -e "\.app$" -e "\.mpkg$" -e "\.pkg$" -e "\.prefPane$"| grep -v -e "${MOUNTPOINT}.*\.mpkg/.*\.pkg$" -e "${MOUNTPOINT}.*\.app/.*\.app$" -e "${MOUNTPOINT}.*\.prefPane/.*\.app$" -e "${MOUNTPOINT}.*\.prefPane/.*\.pkg$" -e "${MOUNTPOINT}.*\.prefPane/.*\.mpkg$"`

	    if [ -z "$APPLICATIONS" ];then
		APP_NAME=`basename ${FILENAME}`
		echo "${APP_NAME} does not contain any applications to install."
	    fi

	    APP_COUNT=`echo "$APPLICATIONS" | wc -l`
	    if [ $APP_COUNT -gt 1 ];then
		APPLICATIONS=`echo "$APPLICATIONS" | grep -i -v -e "uninstall.*\.mpkg$" -e "uninstall.*\.pkg$" -e "remove.*\.mpkg$" -e "remove.*\.pkg"`
	    fi

	    IFS=$'\n'
	    for i in $APPLICATIONS;do
		installApplication "$i"
	    done
	    unset IFS
	    hdiutil detach "${MOUNTPOINT}" > /dev/null
	    ;;
	zip)
	    APPLICATIONS=`zipinfo -1 "${FILENAME}" | grep -e "\.app/$" -e "\.pkg$" -e "\.mpkg/$" -e "\.dmg$" -e "\.prefPane/$" | grep -v -e ".*\.mpkg/.*\.pkg$" -e ".*\.app/.*\.app/$" -e ".*\.prefPane/.*\.app/$" -e ".*\.prefPane/.*\.mpkg/$" -e ".*\.prefPane/.*\.pkg$" | grep -i -v "__MACOSX" | sed -e 's#/$##'`

	    if [ -z "$APPLICATIONS" ];then
		APP_NAME=`basename ${FILENAME}`
		echo "${APP_NAME} does not contain any applications to install."
	    fi

	    APP_COUNT=`echo "$APPLICATIONS" | wc -l`
	    if [ $APP_COUNT -gt 1 ];then
		APPLICATIONS=`echo "$APPLICATIONS" | grep -i -v -e "uninstall.*\.mpkg$" -e "uninstall.*\.pkg$" -e "remove.*\.mpkg$" -e "remove.*\.pkg"`
	    fi

	    UNZIPDIR=`dirname ${FILENAME}`

	    unzip -o -qq -d "${UNZIPDIR}" "${FILENAME}" -x '__MACOSX/*' 2> /dev/null
	    IFS=$'\n'
	    for i in $APPLICATIONS;do
		if [ ! -z "$i" ];then
		    installApplication "${UNZIPDIR}/${i}"
		    EXTENSION=${i##*.}
		    case $EXTENSION in
			pkg|mpkg)
			    rm -rf "${UNZIPDIR}/${i}"
			    ;;
		    esac
		fi
	    done
	    unset IFS
	    ;;
	app|pkg|mpkg|alfredextension|prefPane)
	    installApplication "${FILENAME}"
	    ;;
	*)
	    APP_NAME=`basename "${FILENAME}"`
	    echo "Can't install '${APP_NAME}'. Unsupported filetype."
	    ;;
    esac

    # Check which applications were installed
    APP_COUNTER=0
    IFS=$'\n'
    for f in `find /Applications -type d -name "*.app" -prune -ctime -1 -exec stat -f "%c%t%N" {} \; | sort -rn`;do
	CTIME=`echo "$f" | cut -f 1`
	NEW_APPLICATION=`echo "$f" | cut -f 2`
	if [ $CTIME -gt $LATEST_CTIME ];then
	    APP_COUNTER=$(( $APP_COUNTER + 1 ))
	    INSTALLED_APPLICATIONS[${APP_COUNTER}]="$NEW_APPLICATION"
	fi
    done
    unset IFS


    if [ ${#INSTALLED_APPLICATIONS[@]} -gt 0 ];then
	case $AUTO_START in
	    ask)
		if [ ${#INSTALLED_APPLICATIONS[@]} -eq 1 ];then
		    SHORT_NAME=`basename "${INSTALLED_APPLICATIONS[1]}" | sed -e 's/\.app$//'`
		    ACTION=`osascript 2> /dev/null <<-EOF
						tell application "System Events"
							set question to display dialog "You just installed application ${SHORT_NAME}.\n\nDo you want to start it?" buttons {"Yes, start application","No"} default button 1 with title "Alfred Install" with icon caution
							set answer to button returned of question
							return answer
						end tell
					EOF`

		    if [ $? -eq 0 ] && [ "$ACTION" = "Yes, start application" ];then
			xattr -d com.apple.quarantine "${INSTALLED_APPLICATIONS[1]}" 2>/dev/null
			open -a "${INSTALLED_APPLICATIONS[1]}"
			echo "Application '${SHORT_NAME}' started."
		    fi
		else
		    IFS=$'\n'
		    for a in ${INSTALLED_APPLICATIONS[@]};do
			LIST="${LIST}\"`basename "${a}" | sed -e 's/\.app$//'`\""
		    done
		    unset IFS
		    LIST=`echo "$LIST" | sed -e 's/""/","/g'`
		    ACTION=`osascript 2> /dev/null <<-EOF
						tell application "System Events"
							set theList to { ${LIST} }
							choose from list theList with title "Alfred Install" with prompt "Several new installed applications were found.\n\nDo you want to start one?" OK button name "Start selected application" cancel button name "Cancel"
							return result
						end tell
					EOF`

		    if [ $? -eq 0 ];then
			find /Applications -type d -name "${ACTION}.app" -exec xattr -d com.apple.quarantine {} \; 2> /dev/null
			open -a "${ACTION}.app"
			echo "Application '${ACTION}' started."
		    fi
		fi
		;;
	    always)
		if [ ${#INSTALLED_APPLICATIONS[@]} -eq 1 ];then
		    xattr -d com.apple.quarantine "${INSTALLED_APPLICATIONS[1]}" 2>/dev/null
		    open -a "${INSTALLED_APPLICATIONS[1]}"
		    echo "Application '`basename "${INSTALLED_APPLICATIONS[1]}" | sed -e 's/\.app$//'`' started."
		else
		    IFS=$'\n'
		    for a in ${INSTALLED_APPLICATIONS[@]};do
			LIST="${LIST}\"`basename "${a}" | sed -e 's/\.app$//'`\""
		    done
		    unset IFS
		    LIST=`echo "$LIST" | sed -e 's/""/","/g'`
		    ACTION=`osascript 2> /dev/null <<-EOF
						tell application "System Events"
							set theList to { ${LIST} }
							choose from list theList with title "Alfred Extension" with prompt "Several new installed applications were found.\n\nSelect which one you want to start:" OK button name "Select" cancel button name "Cancel"
							return result
						end tell
					EOF`

		    if [ $? -eq 0 ];then
			find /Applications -type d -name "${ACTION}.app" -exec xattr -d com.apple.quarantine {} \; 2> /dev/null
			open -a "${ACTION}.app"
			echo "Application '${ACTION}' started."
		    fi
		fi
		;;
	    never)
		# do nothing
		;;
	esac
    fi
}

while getopts ":rd:s:" opt; do
    case $opt in
        r)
    	    INSTALL_MOST_RECENT="Y"
    	    ;;
        d)
    	    INSTALL_DIR=$OPTARG
    	    ;;
        s)
    	    AUTO_START=$OPTARG # ask, always or never
    	    ;;
        \?)
    	    echo "Invalid option: -$OPTARG" >&2
    	    ;;
    esac
done
shift $((OPTIND-1))

INSTALL_DIR=${INSTALL_DIR:-~/Downloads}
AUTO_START=${AUTO_START:-"ask"}

if [ -z "$1" ];then
    if [ "${INSTALL_MOST_RECENT}" = "Y" ];then
	FILENAMES=`bash recent.sh -d "${INSTALL_DIR}" -- "list 15" | grep -e "\.pkg$" -e "\.zip$" -e "\.dmg$" -e "\.app$" -e "\.mpkg$" -e "\.alfredextension$" -e "\.prefPane$" | head -n 1`
    fi
else
    set -- $1
    shopt -s nocasematch
    case $1 in
	l|last)
	    NUMBER_OF_FILES=${2:-1}
	    FILENAMES=`bash recent.sh -d "${INSTALL_DIR}" -- "list 15" | grep -e "\.pkg$" -e "\.zip$" -e "\.dmg$" -e "\.app$" -e "\.mpkg$" -e "\.alfredextension$" -e "\.prefPane$"  | head -n ${NUMBER_OF_FILES}`
	    ;;
	[0-9]|[0-9][0-9])
	    FILENAMES=`bash recent.sh -d "${INSTALL_DIR}" -- "list 25" | head -n $1 | tail -n 1`
	    shift
	    if [ ! -z "$@" ];then
		for i in "$@";do
		    FILENAMES="${FILENAMES}"$'\n'`bash recent.sh -d "${INSTALL_DIR}" -- "list 25" | head -n $1 | tail -n 1`
		done
	    fi
	    ;;
	*)
	    case ${1:0:1} in
		/|\~)
		    FILENAMES=${FILENAMES:-`cd ${INSTALL_DIR} && eval echo "$@"`}
		    ;;
		*)
		    if [ ${#1} -lt 3 ];then
			echo "Minimum length for software search is 3. Aborting."
			exit 1
		    else
			FILENAMES=${FILENAMES:-`find "${INSTALL_DIR}" \( \( -type f -ipath "*${1}*" \) -o \( -type d -name "*.app" -prune -o -name "*.mpkg" -prune -o -name "*.prefPane" -prune \) \) -exec stat -f "%c%t%N" {} \; | sort -rn | grep -e "\.pkg$" -e "\.zip$" -e "\.dmg$" -e "\.app$" -e "\.mpkg$" -e "\.alfredextension$" -e "\.prefPane$" | head -n 1 | cut -f 2`}
		    fi
		    ;;
	    esac
	    ;;
    esac
fi

if [ -z "${FILENAMES}" ];then
    echo "Nothing to install. Aborting."
    exit 0
fi

IFS=$'\n'
for i in $FILENAMES;do

    EXTENSION=${i##*.}

    case $EXTENSION in
	app|mpkg)
	    if [ ! -d "${i}" ];then
		echo "Unable to find folder '${i}'. Aborting."
		exit 1
	    fi
	    ;;
	*)
	    if [ ! -f "${i}" ];then
		echo "Unable to find file '${i}'. Aborting."
		exit 1
	    fi
	    ;;
    esac
    #echo "Installing ${i}."
    installSoftware "${i}"
done
unset IFS
