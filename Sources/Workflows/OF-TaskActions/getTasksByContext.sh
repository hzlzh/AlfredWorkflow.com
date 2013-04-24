#!/bin/bash

. workflowHandler.sh

QUERY=$1
CONTEXT=${QUERY}
THEME=$(getPref theme 1)

OFOC="com.omnigroup.OmniFocus"
if [ ! -d "$HOME/Library/Caches/$OFOC" ]; then OFOC=$OFOC.MacAppStore; fi

ZONERESET=$(date +%z | awk '
{if (substr($1,1,1)!="+") {printf "+"} else {printf "-"} print substr($1,2,4)}') 
YEARZERO=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "2001-01-01 0:0:0 $ZONERESET" "+%s")
START="($YEARZERO + t.dateToStart)";
DUE="($YEARZERO + t.dateDue)";

getSubContexts() {
  local SQL_CHILD="SELECT c.persistentIdentifier FROM Context c WHERE c.parent = '$1'"
  local OLDIFS="$IFS"
  IFS='
'
  local CHILDREN=$(sqlite3 ${HOME}/Library/Caches/${OFOC}/OmniFocusDatabase2 "${SQL_CHILD}")
  local IDS=""

  for C in ${CHILDREN[*]}; do
    IDS="$IDS,'$C'$(getSubContexts $C)"
  done

  IFS="$OLDIFS"

  echo "$IDS"
}

getContexts() {
  local SQL_PARENT="SELECT c.persistentIdentifier FROM Context c WHERE c.name = '$1'"
  local PARENT=$(sqlite3 ${HOME}/Library/Caches/${OFOC}/OmniFocusDatabase2 "${SQL_PARENT}")
  local IDS="'${PARENT}'$(getSubContexts ${PARENT})"
  echo "$IDS"
}

SQL="SELECT t.persistentIdentifier, t.name, strftime('%Y-%m-%d %H:%M',${START}, 'unixepoch'), strftime('%Y-%m-%d %H:%M',${DUE}, 'unixepoch'), t.isDueSoon, t.isOverdue, t.flagged, t.repetitionMethodString, t.repetitionRuleString, c.name, p.name FROM Task t, (Task tt left join ProjectInfo pp ON tt.persistentIdentifier = pp.pk ) p, Context c WHERE t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.containingProjectInfo = p.pk AND t.context = c.persistentIdentifier AND c.persistentIdentifier IN ($(getContexts ${CONTEXT}))"

OLDIFS="$IFS"
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
  REST=${REST#*|}
  TCONTEXT=${REST%%|*}
  TPROJECT=${REST##*|}

  addResult "${TID}" "${T}|0" "${TNAME} (${TPROJECT})" "Start: ${TSTART}  |  Due: ${TDUE}  |  Context: ${TCONTEXT}" "img/detail/${THEME}/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
done

IFS="$OLDIFS"

getXMLResults

