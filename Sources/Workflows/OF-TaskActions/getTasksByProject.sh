#!/bin/bash

. workflowHandler.sh

QUERY=$1
PROJECT=${QUERY}
THEME=$(getPref theme 1)

OFOC="com.omnigroup.OmniFocus"
if [ ! -d "$HOME/Library/Caches/$OFOC" ]; then OFOC=$OFOC.MacAppStore; fi

ZONERESET=$(date +%z | awk '
{if (substr($1,1,1)!="+") {printf "+"} else {printf "-"} print substr($1,2,4)}') 
YEARZERO=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "2001-01-01 0:0:0 $ZONERESET" "+%s")
START="($YEARZERO + t.dateToStart)";
DUE="($YEARZERO + t.dateDue)";

SQL="SELECT t.persistentIdentifier, t.name, strftime('%Y-%m-%d %H:%M',${START}, 'unixepoch'), strftime('%Y-%m-%d %H:%M',${DUE}, 'unixepoch'), t.isDueSoon, t.isOverDue, t.flagged, t.repetitionMethodString, t.repetitionRuleString, c.name FROM Task t left join Context c ON t.context = c.persistentIdentifier, (Task ttt left join ProjectInfo pp ON ttt.persistentIdentifier = pp.pk ) p WHERE t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.containingProjectInfo = p.pk AND p.name = '${PROJECT}'"

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
  REST=${REST#*|}
  TREPTYPE=${REST%%|*}
  REST=${REST#*|}
  TREPRULE=${REST%%|*}
  CONTEXT=${REST##*|}

  addResult "${TID}" "${T}|${PROJECT}|0" "${TNAME} (${PROJECT})" "Start: ${TSTART}  |  Due: ${TDUE}  |  Context: ${CONTEXT}" "img/detail/${THEME}/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
done

getXMLResults

IFS=$OLDIFS
