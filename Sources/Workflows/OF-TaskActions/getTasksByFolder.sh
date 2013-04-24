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

getSubFolders() {
  local SQL_CHILD="SELECT f.persistentIdentifier FROM Folder f WHERE f.parent = '$1'"
  local OLDIFS="$IFS"
  IFS='
'
  local CHILDREN=$(sqlite3 ${HOME}/Library/Caches/${OFOC}/OmniFocusDatabase2 "${SQL_CHILD}")
  local IDS=""

  for F in ${CHILDREN[*]}; do
    IDS="$IDS,'$F'$(getSubFolders $F)"
  done

  IFS="$OLDIFS"

  echo "$IDS"
}

getFolders() {
  local SQL_PARENT="SELECT f.persistentIdentifier FROM Folder f WHERE f.name = '$1'"
  local PARENT=$(sqlite3 ${HOME}/Library/Caches/${OFOC}/OmniFocusDatabase2 "${SQL_PARENT}")
  local IDS="'${PARENT}'$(getSubFolders ${PARENT})"
  echo "$IDS"
}

SQL="SELECT t.persistentIdentifier, t.name, strftime('%Y-%m-%d %H:%M',${START}, 'unixepoch'), strftime('%Y-%m-%d %H:%M',${DUE}, 'unixepoch'), t.isDueSoon, t.isOverdue, t.flagged, t.repetitionMethodString, t.repetitionRuleString, c.name, p.name FROM (((task tt left join projectinfo pi on tt.containingprojectinfo=pi.pk) t left join task p on t.task=p.persistentIdentifier) left join context c on t.context = c.persistentIdentifier) left join folder f on t.folder=f.persistentIdentifier WHERE t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.status = 'active' AND f.active = 1 AND t.folder IN ($(getFolders ${QUERY}))"

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

