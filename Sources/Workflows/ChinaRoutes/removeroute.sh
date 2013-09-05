#!/bin/bash

OLDGW=`cat /tmp/oldgw`;
for ip in ` awk '{print $1}' ip`
{
    route delete $ip $OLDGW;
}
rm -rf /tmp/oldgw;