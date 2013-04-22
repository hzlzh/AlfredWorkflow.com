#!/bin/bash

. workflowHandler.sh

THEME=$(getPref theme 1)

OFOC="com.omnigroup.OmniFocus"
if [ ! -d "$HOME/Library/Caches/$OFOC" ]; then OFOC=$OFOC.MacAppStore; fi

ZONERESET=$(date +%z | awk '
{if (substr($1,1,1)!="+") {printf "+"} else {printf "-"} print substr($1,2,4)}') 
YEARZERO=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "2001-01-01 0:0:0 $ZONERESET" "+%s")
START="($YEARZERO + t.dateToStart)";
DUE="($YEARZERO + t.dateDue)";

SQL="SELECT t.persistentIdentifier, t.name, strftime('%Y-%m-%d %H:%M',${START}, 'unixepoch'), strftime('%Y-%m-%d %H:%M',${DUE}, 'unixepoch'), t.isDueSoon, t.isOverDue, t.flagged, t.repetitionMethodString, t.repetitionRuleString FROM Task t WHERE t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.inInbox = 1"

OLDIFS=$IFS
IFS='
'
TASKS=$(sqlite3 ${HOME}/Library/Caches/${OFOC}/OmniFocusDatabase2 "${SQL}")

for T in ${TASKS[*]}; do
  TID=${T%%|*}
  REST=${T#*|}
  TNAME=${REST%%|*}
  REST=${REST#*|}
  TSTART=${REST%%|*}
  REST=${REST#*|}
  TDUE=${REST%%|*}
  REST=${REST#*|}
  TSOON=${REST%%|*}
  REST=${REST#*|}
  TOVERDUE=${REST%%|*}
  REST=${REST#*|}
  TFLAGGED=${REST%%|*}

  addResult "${TID}" "${T}|||0" "${TNAME}" "Start: ${TSTART}  |  Due: ${TDUE}" "img/detail/${THEME}/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
done

getXMLResults

IFS=$OLDIFS
