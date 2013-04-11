#!/bin/bash

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

# get name of script
me=`basename $0`
