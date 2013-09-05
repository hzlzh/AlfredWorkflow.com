#!/bin/bash

OLDGW=`netstat -nr | grep '^default' | grep -v 'ppp' | sed 's/default *\([0-9\.]*\) .*/\1/' | sed '/^$/d'`

for ip in ` awk '{print $1}' ip`
{
    route -n add -net $ip $OLDGW;
}

echo $OLDGW > /tmp/oldgw;