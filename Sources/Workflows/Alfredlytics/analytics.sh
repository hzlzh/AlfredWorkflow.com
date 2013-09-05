#!/bin/bash

. workflowHandler.sh

RANDOM=$(date +"%s")
QUERY="$1"

showMenue() {
    addResult "${RANDOM}1" "visitors" "Google Analytics :: Visits/Pageviews" "Show visits/pageviews of the last 7 days" "visitors.png" "yes"
    addResult "${RANDOM}2" "pages" "Google Analytics :: Top Pages" "Show top pages of the last 30 days" "pages.png" "yes"
    addResult "${RANDOM}3" "referrers" "Google Analytics :: Top Referrers" "Show top referrers of the last 30 days" "referrers.png" "yes"
    addResult "${RANDOM}4" "searches" "Google Analytics :: Top Searches" "Show top searches of the last 30 days" "searches.png" "yes"
}

getToken() {
    local ATOKEN=$(getPref "atoken" 1)

    if [ -z "$ATOKEN" ]; then
        local AUTH=$(getPref "acode" 1)
        local RESPONSE=$(./ga -t "$AUTH")
        local ATOKEN=$(echo "$RESPONSE" | grep "access" | cut -d "|" -f 2)
        local RTOKEN=$(echo "$RESPONSE" | grep "refresh" | cut -d "|" -f 2)
        setPref "atoken" "$ATOKEN" 1
        setPref "rtoken" "$RTOKEN" 1
    else
        local EXPIRED=$(./ga -e "$ATOKEN")

        if [ "$EXPIRED" == "1" ]; then
            local REFRESH=$(getPref "rtoken" 1)
            local ATOKEN=$(./ga -r "$REFRESH")
			setPref "atoken" "$ATOKEN" 1
        fi
    fi
    echo "$ATOKEN"
}

showMetrics() {
    local ATOKEN=$(getToken)
    local PROFILE=$(getPref "profile" 1)

    local ARG="$1"
    local METRICS=(${ARG//,/ })
    local ANALYTICS=()
    local DATES=()

    for i in $(seq 0 6); do
        local STARTDATE=$(date -v-${i}d +"%Y-%m-%d")
        DATES+=("$STARTDATE")
        local RESPONSE=$(./ga -m "$PROFILE" "$ARG" "" "$STARTDATE" "$STARTDATE" "$2" "$ATOKEN" | ./JSON.sh -b | grep "totalsForAllResults")
        for METRIC in ${METRICS[*]}; do
            local VALUE=$(echo "$RESPONSE" | grep "$METRIC" | cut -d "]" -f 2 | cut -d "\"" -f 2)
            ANALYTICS+=("$VALUE")
        done
    done

    local MAX=$(echo "${ANALYTICS[@]}" | awk -v RS=" " '1' | sort -nr | head -1)
    local METCOUNT=${#METRICS[*]}

    for i in $(seq 0 6); do
        local SHOWDATE=${DATES[i]}
        local SHOWVALUE=""
        local FIRSTVAL=0
		local LASTVAL=0
        for c in ${!METRICS[*]}; do
            local IDX=$(expr $i \* $METCOUNT + $c)
            local VAL=$(expr ${ANALYTICS[IDX]} - $FIRSTVAL)
            for x in $(seq $(expr 30 \* $VAL / $MAX)); do
                if [ "$(expr $c % 2)" == "0" ]; then
                    FIRSTVAL="$VAL"
                    SHOWVALUE="${SHOWVALUE}▣"
                else
					LASTVAL=$(expr $FIRSTVAL + $VAL)
                    SHOWVALUE="${SHOWVALUE}▢"
                fi
            done
        done
		addResult "$RANDOM1" "notused" "$SHOWVALUE" "$SHOWDATE   |   Visitors: $FIRSTVAL   |   Pageviews: $LASTVAL" "$3.png" "no"
    done
}

showDimensions() {
    local ATOKEN=$(getToken)
    local PROFILE=$(getPref "profile" 1)
    local ENDDATE=$(date +"%Y-%m-%d")
    local STARTDATE=$(date -v-30d +"%Y-%m-%d")

	OLDIFS="$IFS"
	IFS='
'

    local DIMENSIONS=$(./ga -m "$PROFILE" "$1" "$2" "$STARTDATE" "$ENDDATE" "$3" "$ATOKEN" | ./JSON.sh -b | grep "rows" | cut -d "]" -f 2 | cut -d "\"" -f 2 | paste -d '|' - -)

	local COUNT=1
	for D in ${DIMENSIONS[*]}; do
		local TITLE=${D%%|*}
		local VAL=${D##*|}

		addResult "$RANDOM" "notused" "$TITLE" "Pageviews: $VAL" "$4.png" "no"

		let COUNT+=1
		if [ "$COUNT" == "10" ]; then
			break
		fi
	done
	
	IFS="$OLDIFS"
}

main() {
    if [ -z "$QUERY" ]; then
        showMenue
    else
        case "$QUERY" in
            visitors)
                showMetrics "ga:visitors,ga:pageviews" "" "visitors"
                ;;
            pages)
                showDimensions "ga:pageviews" "ga:pagePath" "-ga:pageviews" "pages"
                ;;
            referrers)
                showDimensions "ga:pageviews" "ga:source" "-ga:pageviews" "referrers"
                ;;
            searches)
                showDimensions "ga:pageviews" "ga:keyword" "-ga:pageviews" "searches"
                ;;
        esac
    fi
	getXMLResults
}

main
