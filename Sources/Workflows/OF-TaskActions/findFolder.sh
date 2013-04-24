#!/bin/bash

QUERY=$1

OFOC="com.omnigroup.OmniFocus"
if [ ! -d "$HOME/Library/Caches/$OFOC" ]; then OFOC=$OFOC.MacAppStore; fi

SQL="SELECT persistentIdentifier, name, numberOfAvailableTasks FROM Folder WHERE active = 1 AND lower(name) LIKE lower('%${QUERY}%')"

OLDIFS=$IFS
IFS='
'
FOLDERS=$(sqlite3 ${HOME}/Library/Caches/${OFOC}/OmniFocusDatabase2 "${SQL}")

echo "<?xml version='1.0'?><items>"

for F in ${FOLDERS[*]}; do
  FID=${F%%|*}
  REST=${F#*|}
  FNAME=${REST%%|*}
  FTCOUNT=${REST##*|}
  echo "<item uid='${FID}' arg='${FNAME}'><title>${FNAME}</title><subtitle>Available Tasks: ${FTCOUNT}</subtitle><icon>img/folder.png</icon></item>"
done
echo "</items>"

IFS=$OLDIFS
