#!/bin/bash

. workflowHandler.sh

THEME=$(getPref theme 1)
TASK=$(getPref task 0)
SEARCH=$(getPref lastSearch 0)

OLDIFS="$IFS"
IFS="|"

T=($TASK)

TID=${T[0]}
TNAME=${T[1]}
TSTART=${T[2]}
TDUE=${T[3]}
TSOON=${T[4]}
TOVERDUE=${T[5]}
TFLAGGED=${T[6]}
TREPTYPE=${T[7]}
TREPRULE=${T[8]}
CONTEXT=${T[9]}
PROJECT=${T[10]}
TDONE=${T[11]}

RANDOMUID=$(date +"%s")=

addResult "${RANDOMUID}1" "back" "Back" "Go back to previous search" "img/detail/${THEME}/back.png" "yes"

if [ "$TDONE" = "1" ]; then
  addResult "${RANDOMUID}2" "done" "${TNAME}" "[↩] Uncheck" "img/detail/${THEME}/done.png" "yes"
else
  addResult "${RANDOMUID}3" "done" "${TNAME}" "[↩] Check" "img/detail/${THEME}/task${TFLAGGED}${TSOON}${TOVERDUE}.png" "yes"
fi
addResult "${RANDOMUID}4" "project" "${PROJECT}" "[↩] Go to project   [⌘] Change project" "img/detail/${THEME}/project.png" "yes"
addResult "${RANDOMUID}5" "context" "${CONTEXT}" "[↩] Go to context   [⌘] Change context" "img/detail/${THEME}/context.png" "yes"
addResult "${RANDOMUID}6" "deferstart" "${TSTART}" "[↩] Defer start date" "img/detail/${THEME}/start.png" "yes"
addResult "${RANDOMUID}7" "deferdue" "${TDUE}" "[↩] Defer due date" "img/detail/${THEME}/due.png" "yes"

if [ "${TFLAGGED}" = "0" ]; then
  addResult "${RANDOMUID}8" "flag" "Flag" "[↩] Flag" "img/detail/${THEME}/flag.png" "yes"
else
  addResult "${RANDOMUID}9" "flag" "Un-Flag" "[↩] Un-Flag" "img/detail/${THEME}/flag.png" "yes"
fi
addResult "${RANDOMUID}10" "note" "Add Note" "[↩] Add note" "img/detail/${THEME}/clip.png" "yes"
addResult "${RANDOMUID}11" "${SEARCH:4:1}view" "Show in OF" "[↩] Open the task in OF" "img/detail/${THEME}/view.png" "yes"

getXMLResults

IFS="$OLDIFS"
