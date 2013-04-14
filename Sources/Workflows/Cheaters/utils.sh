#!/bin/bash

# xargs strips leading/trailing whitespace and quotes. tr removes () chars
# usage: OUTPUT=$(alf_remove_spesh "$OUTPUT")
function alf_remove_spesh(){

    local result=`echo "$1" | xargs | tr -d '()'`
    echo "$result"
}

# check if a file/folder/link exists
alf_file_exists() {
    if [ -e "$1" ]; then
      return 0
    fi
    return 1
}

# add -t param to tag log in syslog
loggerCmd="logger -t 'Alfred Workflow'"

# Success logging
alf_success() {
    eval $loggerCmd "SUCCESS: $@"
}

# debug logging
alf_debug() {
    eval $loggerCmd "DEBUG: $@"
}

# error logging
alf_error() {
    eval $loggerCmd "ERROR: $@"
}

# get present working dir
PWD=`pwd`

alf_is_git_repo() {
    $(git rev-parse --is-inside-work-tree &> /dev/null)
}

# Test whether a command exists
alf_type_exists() {
    if [ $(type -P $1) ]; then
      return 0
    fi
    return 1
}

# Git status information
alf_git_status() {
    local git_state uc us ut st
	git update-index --really-refresh  -q &>/dev/null

    # Check for uncommitted changes in the index
    if ! $(git diff --quiet --ignore-submodules --cached); then
        uc="+"
    fi

    # Check for unstaged changes
    if ! $(git diff-files --quiet --ignore-submodules --); then
        us="!"
    fi

    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        ut="?"
    fi

    # Check for stashed files
    if $(git rev-parse --verify refs/stash &>/dev/null); then
        st="$"
    fi

    git_state=$uc$us$ut$st

    echo $git_state

}

alf_git_overwrite() {

user_response=$(osascript <<EOF
tell application "System Events"
	activate
	set userCanceled to false
	try
		set alertResult to display alert "Your git repo has local changes, do you want to over-write them?" ¬
			message "Your local changes will be LOST if you click YES" ¬
	    	buttons {"No", "Yes"} as warning ¬
	    	default button "No" cancel button "No" giving up after 5
	on error number -128
    	set userCanceled to true
	end try

	if userCanceled then
	    set alertResult to "NO"
	else if gave up of alertResult then
	    set alertResult to "NO"
	else if button returned of alertResult is "Yes" then
		set alertResult to "YES"
	end if
end tell

EOF)

echo "$user_response"

}
