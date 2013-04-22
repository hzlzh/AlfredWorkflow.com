#!/bin/bash

QUERY=$1

OFOC="com.omnigroup.OmniFocus"
if [ ! -d "$HOME/Library/Caches/$OFOC" ]; then OFOC=$OFOC.MacAppStore; fi

SQL="SELECT persistentIdentifier, name, availableTaskCount FROM Context WHERE active = 1 AND lower(name) LIKE lower('%${QUERY}%')"

OLDIFS=$IFS
IFS='
'
CONTEXTS=$(sqlite3 ${HOME}/Library/Caches/${OFOC}/OmniFocusDatabase2 "${SQL}")

echo "<?xml version='1.0'?><items>"

for C in ${CONTEXTS[*]}; do
  CID=${C%%|*}
  REST=${C#*|}
  CNAME=${REST%%|*}
  CTCOUNT=${REST##*|}
  echo "<item uid='ofcontext' arg='${CNAME}'><title>${CNAME##*= }</title><subtitle>Available Tasks: ${CTCOUNT}</subtitle><icon>img/context.png</icon></item>"
done
echo "</items>"

IFS=$OLDIFS
