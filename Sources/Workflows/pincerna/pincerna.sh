#!/bin/bash
#
# This file is part of the pincerna gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

PORT=$((13000 + $UID))
HOST=http://localhost:$PORT
TYPE=$1
shift
QUERY=$@

# Check the status of the server and start it if needed.
curl -o /dev/null -s $HOST/status

if [ "$?" != "0" -a "$QUERY" != "quit" ]; then
  [ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm"
  pincernad -e production -p $PORT -d
fi

# Perform the request.
curl -X GET -s --data-urlencode "q=$QUERY" http://localhost:$PORT/$TYPE
