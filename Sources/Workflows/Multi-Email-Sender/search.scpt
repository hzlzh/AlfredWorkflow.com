on run argv
tell application "Contacts"
	set _tosearch to item 1 of argv
	set _answer to ""
	repeat with oneID in (get id of every person whose name contains _tosearch)
		set oneID to contents of oneID
		set dataList to (get every email of person id oneID)
		repeat with oneValue in dataList
			set _answer to _answer & value of oneValue & "!:!" & name of person id oneID & "\n"
			
		end repeat
	end repeat
	_answer
end tell
end run
