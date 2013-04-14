#!/bin/bash

source utils.sh

# we need two workflows
# one is an AppleScript that runs the other
# and then kills the "Automator Launcher"
# this stops the spinning automator gear in the menu bar
WF="$PWD/Cheaters.workflow"
WF2="$PWD/CheatersRunner.workflow"

# quick check to see they exist
if ! alf_file_exists $WF ; then
	OUTPUT="$WF NOT found, cannot continue"
	alf_error $OUTPUT
	echo "ERROR $OUTPUT"
	exit
fi

if ! alf_file_exists $WF2 ; then
	OUTPUT="$WF2 NOT found, cannot continue"
	alf_error $OUTPUT
	echo "ERROR $OUTPUT"
	exit
fi

# check git is installed
if ! alf_type_exists git ; then
	OUTPUT="git is NOT installed, cannot continue"
	alf_error $OUTPUT
	echo "ERROR $OUTPUT"
	exit
fi

#alf_debug "git installed"

if alf_file_exists cheaters ; then
	#alf_debug "cheaters dir exists"
	cd cheaters

	# check is git repo
	if ! alf_is_git_repo ; then
		OUTPUT="NOT a git repo"
		alf_error $OUTPUT
		echo "ERROR $OUTPUT"
		exit
	else
		#alf_debug "is a git repo"
		git_info=$(alf_git_status)

		#alf_debug "git_info = [$git_info]"

		if [ "$git_info" != "" ]
			then
				alf_debug "GIT not clean"
				# ask user if they want to reset
				git_overwrite=$(alf_git_overwrite)

				alf_debug "git_overwrite = [$git_overwrite]"

				if [ "$git_overwrite" == "YES" ]
				then
					alf_debug "git_overwrite = YES, updating"
					# this will just overwrite any uncommitted/stashed/tracked
					# files in the current branch to the local HEAD.
					git reset --hard HEAD
				else
					alf_debug "git_overwrite = NO, leaving"
				fi
		else
			alf_debug "GIT clean, updating"
			# not sure we need to do this
			# local branch should be up to date
			# could do something with origin/upstream remotes
			# but not at the moment
			git pull -q
		fi
	fi
else
	alf_debug "cheaters dir does NOT exist, cloning"
	# edit this line if you have your own fork
	git clone -q https://github.com/ttscoff/cheaters.git cheaters
	RC=$?

	if [ $RC -ne 0 ]
	then
		OUTPUT="Could not clone cheaters git repo"
		alf_error $OUTPUT
		echo "ERROR $OUTPUT"
		exit
	else
		alf_debug "cheaters git repo cloned"
		cd cheaters
	fi
fi

output=`automator  -i "file://$PWD/index.html $WF" $WF2  2>&1 `
RC=$?

if [ $RC -ne 0 ]
then
	OUTPUT="$output - $WF2"
	alf_error "$OUTPUT"
	echo "ERROR $OUTPUT"
else
	OUTPUT="Ran $WF2"
	alf_success $OUTPUT
	# don't display a notification on success
	#echo "$OUTPUT"
fi
