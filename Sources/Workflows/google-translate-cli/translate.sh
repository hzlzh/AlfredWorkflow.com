#!/bin/bash
. workflowHandler.sh
result=$( /usr/local/bin/gawk -f ./translate.awk {=zh} "{query}" )

# create feedback entries
# addResult "uid" "arg" "title" "subtitle" "icon" "valid" "autocomplete"
addResult "0" "http://translate.google.com/#auto/zh-CN/{query}" "$result" "powered by google translate" "icon.png" "yes" "autocomplete"

# get feedback xml
getXMLResults
