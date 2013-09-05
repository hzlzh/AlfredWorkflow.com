#!/bin/bash

. workflowHandler.sh

getOFCacheDir() {
	local OFCD="${HOME}/Library/Caches/com.omnigroup.OmniFocus"
	if [ ! -d "$OFCD" ]; then 
		OFCD=$OFCD.MacAppStore;
	fi
	echo "$OFCD"
}

executeQuery() {
	local SQL="$@"
	local OFCD=$(getOFCacheDir)
	sqlite3 ${OFCD}/OmniFocusDatabase2 "$SQL"
}

formatDate() {
	local ZONERESET=$(date +%z | awk '{if (substr($1,1,1)!="+") {printf "+"} else {printf "-"} print substr($1,2,4)}')
	local YEARZERO=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "2001-01-01 0:0:0 $ZONERESET" "+%s")
	echo "strftime('%Y-%m-%d %H:%M',($YEARZERO + $1), 'unixepoch')";
}

findFolder() {
	local SELECT="f.persistentIdentifier, f.name, f.numberOfAvailableTasks"
	local FROM="Folder f"
	local WHERE="f.active = 1 AND lower(f.name) LIKE lower('%$@%')"
	local ORDER="f.name ASC"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE ORDER BY $ORDER"

	local OLDIFS="$IFS"
	IFS='
'

	local DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
		local FID=${R%%|*}
		local REST=${R#*|}
		local FNAME=${REST%%|*}
		local FTCOUNT=${REST##*|}

		addResult "$FID" "$FNAME" "$FNAME" "Available Tasks: $FTCOUNT" "img/folder.png" "yes"
	done
	IFS="$OLDIFS"
}

findProject() {
	local SELECT="p.pk, t.name, p.status, p.numberOfAvailableTasks, p.numberOfRemainingTasks, p.containsSingletonActions, f.name"
	local FROM="(ProjectInfo p LEFT JOIN Task t ON p.task=t.persistentIdentifier) LEFT JOIN Folder f ON p.folder=f.persistentIdentifier"
	local WHERE="p.status = 'active' AND lower(t.name) LIKE lower('%$@%')"
	local ORDER="p.containsSingletonActions DESC, t.name ASC"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE ORDER BY $ORDER"

	local OLDIFS="$IFS"
	IFS='
'
	local DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
		local PID=${R%%|*}
		local REST=${R#*|}
		local PNAME=${REST%%|*}
		REST=${REST#*|}
		local PSTATUS=${REST%%|*}
		REST=${REST#*|}
		local PAVAILABLE=${REST%%|*}
		REST=${REST#*|}
		local PREMAINING=${REST%%|*}
		REST=${REST#*|}
		local PSINGLE=${REST%%|*}
		local PFOLDER=${REST##*|}

		addResult "$PID" "$PNAME" "$PNAME ($PFOLDER)" "Status: $PSTATUS  |  Available Tasks: $PAVAILABLE" "img/project${PSINGLE}.png" "yes"
	done
	IFS="$OLDIFS"
}

findContext() {
	local SELECT="c.persistentIdentifier, c.name, c.availableTaskCount"
	local FROM="Context c"
	local WHERE="c.effectiveActive = 1 AND lower(c.name) LIKE lower('%$@%')"
	local ORDER="c.name ASC"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE ORDER BY $ORDER"

	local OLDIFS="$IFS"
	IFS='
'

	local DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
		local CID=${R%%|*}
		local REST=${R#*|}
		local CNAME=${REST%%|*}
		local CTCOUNT=${REST##*|}

	addResult "$CID" "$CNAME" "$CNAME" "Available Tasks: $CTCOUNT" "img/context.png" "yes"
	done
	IFS="$OLDIFS"
}

findPerspective() {
	local OLDIFS="$IFS"
	IFS='
'
	local ASRESULTS=$(/usr/bin/osascript ./bin/offv.scpt "$@")

	for R in ${ASRESULTS[*]}; do
		addResult "$R" "$R" "$R" "" "img/perspective.png" "yes"
	done
	IFS="$OLDIFS"
}

getTasksInInbox() {
	local SELECT="t.persistentIdentifier, t.name, $(formatDate 't.dateToStart'), $(formatDate 't.dateDue'), t.isDueSoon, t.isOverDue, t.flagged, t.repetitionMethodString, t.repetitionRuleString"
	local FROM="Task t"
	local WHERE="t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.inInbox = 1"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE"

	local OLDIFS="$IFS"
	IFS='
'
	local DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
		local TID=${R%%|*}
		local REST=${R#*|}
		local TNAME=${REST%%|*}
		REST=${REST#*|}
		local TSTART=${REST%%|*}
		REST=${REST#*|}
		local TDUE=${REST%%|*}
		REST=${REST#*|}
		local TSOON=${REST%%|*}
		REST=${REST#*|}
		local TOVERDUE=${REST%%|*}
		REST=${REST#*|}
		local TFLAGGED=${REST%%|*}

		addResult "$TID" "${R}|||0" "$TNAME" "Start: $TSTART  |  Due: $TDUE" "img/detail/$(getTheme)/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
	done
	IFS="$OLDIFS"

}

getTasksDoneToday() {
	local START_OF_DAY=$(date -v0H -v0M -v0S +%s)

	local SELECT="t.persistentIdentifier, t.name, $(formatDate 't.dateToStart'), $(formatDate 't.dateDue'), t.isDueSoon, t.isOverdue, t.flagged, t.repetitionMethodString, t.repetitionRuleString, c.name, p.name"
	local FROM="Task t, (Task tt left join ProjectInfo pp ON tt.persistentIdentifier = pp.pk ) p, Context c"
	local WHERE="t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.containingProjectInfo = p.pk AND t.context = c.persistentIdentifier AND t.dateCompleted IS NOT NULL AND $(formatDate 't.dateCompleted') > $START_OF_DAY"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE"

	local OLDIFS="$IFS"
	IFS='
'
	local DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
		local TID=${R%%|*}
		local REST=${R#*|}
		local TNAME=${REST%%|*}
		REST=${REST#*|}
		local TSTART=${REST%%|*}
		REST=${REST#*|}
		local TDUE=${REST%%|*}
		REST=${REST#*|}
		local TSOON=${REST%%|*}
		REST=${REST#*|}
		local TOVERDUE=${REST%%|*}
		REST=${REST#*|}
		local TFLAGGED=${REST%%|*}
		REST=${REST#*|}
		local TREPTYPE=${REST%%|*}
		REST=${REST#*|}
		local TREPRULE=${REST%%|*}
		REST=${REST#*|}
		local TCONTEXT=${REST%%|*}
		local TPROJECT=${REST##*|}

		addResult "${TID}" "${R}|1" "${TNAME} (${TPROJECT})" "Start: ${TSTART}  |  Due: ${TDUE}  |  Context: ${TCONTEXT}" "img/detail/$(getTheme)/done.png" "yes"
	done
	IFS="$OLDIFS"
}

getSubFolders() {
	local SQL="SELECT persistentIdentifier FROM Folder WHERE parent = '$@'"
	local OLDIFS="$IFS"
	IFS='
'
	local CHILDREN=$(executeQuery "$SQL")
	local IDS=""

	for F in ${CHILDREN[*]}; do
		IDS="$IDS,'$F'$(getSubFolders $F)"
	done
	IFS="$OLDIFS"

	echo "$IDS"
}

getFolderHierarchy() {
	local SQL="SELECT persistentIdentifier FROM Folder WHERE name = '$@'"
	local PARENT=$(executeQuery "$SQL")
	local IDS="'${PARENT}'$(getSubFolders ${PARENT})"
	echo "$IDS"
}


getTasksByFolder() {
	local SELECT="t.persistentIdentifier, t.name, $(formatDate 't.dateToStart'), $(formatDate 't.dateDue'), t.isDueSoon, t.isOverdue, t.flagged, t.repetitionMethodString, t.repetitionRuleString, c.name, p.name"
	local FROM="(((task tt left join projectinfo pi on tt.containingprojectinfo=pi.pk) t left join task p on t.task=p.persistentIdentifier) left join context c on t.context = c.persistentIdentifier) left join folder f on t.folder=f.persistentIdentifier"
	local WHERE="t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.status = 'active' AND f.active = 1 AND t.folder IN ($(getFolderHierarchy $@))"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE"

	local OLDIFS="$IFS"
	IFS='
'

	local DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
		local TID=${R%%|*}
		local REST=${R#*|}
		local TNAME=${REST%%|*}
		REST=${REST#*|}
		local TSTART=${REST%%|*}
		REST=${REST#*|}
		local TDUE=${REST%%|*}
		REST=${REST#*|}
		local TSOON=${REST%%|*}
		REST=${REST#*|}
		local TOVERDUE=${REST%%|*}
		REST=${REST#*|}
		local TFLAGGED=${REST%%|*}
		REST=${REST#*|}
		local TREPTYPE=${REST%%|*}
		REST=${REST#*|}
		local TREPRULE=${REST%%|*}
		REST=${REST#*|}
		local TCONTEXT=${REST%%|*}
		local TPROJECT=${REST##*|}

		addResult "${TID}" "${R}|0" "${TNAME} (${TPROJECT})" "Start: ${TSTART}  |  Due: ${TDUE}  |  Context: ${TCONTEXT}" "img/detail/$(getTheme)/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
	done
	IFS="$OLDIFS"
}

getTasksByProject() {
	local SELECT="t.persistentIdentifier, t.name, $(formatDate 't.dateToStart'), $(formatDate 't.dateDue'), t.isDueSoon, t.isOverDue, t.flagged, t.repetitionMethodString, t.repetitionRuleString, c.name"
	local FROM="Task t left join Context c ON t.context = c.persistentIdentifier, (Task ttt left join ProjectInfo pp ON ttt.persistentIdentifier = pp.pk ) p"
	local WHERE="t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.containingProjectInfo = p.pk AND p.name = '$@'"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE"
	
	local OLDIFS="$IFS"
	IFS='
'

	DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
	    TID=${R%%|*}
	    REST=${R#*|}
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

	    addResult "${TID}" "${R}|$@|0" "${TNAME} ($@)" "Start: ${TSTART}  |  Due: ${TDUE}  |  Context: ${CONTEXT}" "img/detail/$(getTheme)/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
	done
	IFS="$OLDIFS"
}

getSubContexts() {
  local SQL="SELECT c.persistentIdentifier FROM Context c WHERE c.parent = '$@'"
  local OLDIFS="$IFS"
  IFS='
'
  local CHILDREN=$(executeQuery "$SQL")
  local IDS=""

  for C in ${CHILDREN[*]}; do
    IDS="$IDS,'$C'$(getSubContexts $C)"
  done

  IFS="$OLDIFS"

  echo "$IDS"
}

getContextHierarchy() {
  local SQL="SELECT c.persistentIdentifier FROM Context c WHERE c.name = '$@'"
  local PARENT=$(executeQuery "$SQL")
  local IDS="'${PARENT}'$(getSubContexts ${PARENT})"
  echo "$IDS"
}

getTasksByContext() {
	local SELECT="t.persistentIdentifier, t.name, $(formatDate 't.dateToStart'), $(formatDate 't.dateDue'), t.isDueSoon, t.isOverdue, t.flagged, t.repetitionMethodString, t.repetitionRuleString, c.name, p.name"
	local FROM="Task t, (Task tt left join ProjectInfo pp ON tt.persistentIdentifier = pp.pk ) p, Context c"
	local WHERE="t.blocked = 0 AND t.childrenCountAvailable = 0 AND t.blockedByFutureStartDate = 0 AND t.dateCompleted IS NULL AND t.containingProjectInfo = p.pk AND t.context = c.persistentIdentifier AND c.persistentIdentifier IN ($(getContextHierarchy $@))"
	local SQL="SELECT $SELECT FROM $FROM WHERE $WHERE"
	
	local OLDIFS="$IFS"
	IFS='
'

	DBRESULTS=$(executeQuery "$SQL")

	for R in ${DBRESULTS[*]}; do
	    TID=${R%%|*}
	    REST=${R#*|}
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

	    addResult "${TID}" "${R}|0" "${TNAME} (${TPROJECT})" "Start: ${TSTART}  |  Due: ${TDUE}  |  Context: ${TCONTEXT}" "img/detail/$(getTheme)/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
	done
	IFS="$OLDIFS"
}

getTasksByPerspective() {
	local OLDIFS="$IFS"
	IFS='
'

	local ASRESULTS=$(/usr/bin/osascript ./bin/oftv.scpt "$@")

	for R in ${ASRESULTS[*]}; do
	    TID=${R%%|*}
	    REST=${R#*|}
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
		REST=${REST#*|}
	    TPROJECT=${REST%%|*}
	    TDONE=${REST##*|}

	    addResult "${TID}" "${R}" "${TNAME} (${TPROJECT})" "Start: ${TSTART}  |  Due: ${TDUE}  |  Context: ${TCONTEXT}" "img/detail/$(getTheme)/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
	done
	IFS="$OLDIFS"
}

getTaskDetails() {
	local SEARCH=$(getPref lastSearch 0)
	local TASK=$(getPref task 0)

	local OLDIFS="$IFS"
	IFS="|"

	local T=($TASK)
	local TID=${T[0]}
	local TNAME=${T[1]}
	local TSTART=${T[2]}
	local TDUE=${T[3]}
	local TSOON=${T[4]}
	local TOVERDUE=${T[5]}
	local TFLAGGED=${T[6]}
	local TREPTYPE=${T[7]}
	local TREPRULE=${T[8]}
	local CONTEXT=${T[9]}
	local PROJECT=${T[10]}
	local TDONE=${T[11]}

	local RANDOMUID=$(date +"%s")=

	#addResult "${RANDOMUID}1" "back" "Back" "Go back to previous search" "img/detail/$(getTheme)/back.png" "yes"

	if [ "$TDONE" = "1" ]; then
	  addResult "${RANDOMUID}2" "done" "${TNAME}" "[↩] Uncheck" "img/detail/$(getTheme)/done.png" "yes"
	else
	  addResult "${RANDOMUID}3" "done" "${TNAME}" "[↩] Check" "img/detail/$(getTheme)/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
	fi
	addResult "${RANDOMUID}4" "project" "${PROJECT}" "[↩] Go to project   [⌘] Change project" "img/detail/$(getTheme)/project.png" "yes"
	addResult "${RANDOMUID}5" "context" "${CONTEXT}" "[↩] Go to context   [⌘] Change context" "img/detail/$(getTheme)/context.png" "yes"
	addResult "${RANDOMUID}6" "deferstart" "${TSTART}" "[↩] Defer start date" "img/detail/$(getTheme)/start.png" "yes"
	addResult "${RANDOMUID}7" "deferdue" "${TDUE}" "[↩] Defer due date" "img/detail/$(getTheme)/due.png" "yes"

	if [ "${TFLAGGED}" = "0" ]; then
	  addResult "${RANDOMUID}8" "flag" "Flag" "[↩] Flag" "img/detail/$(getTheme)/flag.png" "yes"
	else
	  addResult "${RANDOMUID}9" "flag" "Un-Flag" "[↩] Un-Flag" "img/detail/$(getTheme)/flag.png" "yes"
	fi
	addResult "${RANDOMUID}10" "note" "Add Note" "[↩] Add note" "img/detail/$(getTheme)/clip.png" "yes"
	addResult "${RANDOMUID}11" "${SEARCH:4:1}view" "Show in OF" "[↩] Open the task in OF" "img/detail/$(getTheme)/view.png" "yes"

	IFS="$OLDIFS"
}

getTheme() {
	getPref "theme" 1
}

main() {
	if [ $# -lt 1 ]; then
		echo "Invalid number or arguments."
		exit
	fi

	FUNC="$1"
	QUERY="$2"
	if [ ! -z "$QUERY" ]; then
		QUERY=$(./bin/normalise "$QUERY")
	fi

	if [ "$FUNC" != "oftd" ]; then
		setPref "lastSearch" ".${FUNC} ${QUERY}" 0
	fi

	case "$FUNC" in
		offf)
			findFolder "$QUERY"
			;;
		offp)
			findProject "$QUERY"
			;;
		offc)
			findContext "$QUERY"
			;;
		offv)
			findPerspective "$QUERY"
			;;
		ofti)
			getTasksInInbox
			;;
		ofdt)
			getTasksDoneToday
			;;
		oftf)
			getTasksByFolder "$QUERY"
			;;
		oftp)
			getTasksByProject "$QUERY"
			;;
		oftc)
			getTasksByContext "$QUERY"
			;;
		oftv)
			getTasksByPerspective "$QUERY"
			;;
		oftd)
			getTaskDetails
			;;
	esac

	getXMLResults
}

main "$@"
