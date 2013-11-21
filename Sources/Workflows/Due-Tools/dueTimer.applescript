--
--	Created by: Sean Korzdorfer
--	Created on: 04/23/13 19:53:16
--
--	Copyright (c) 2013 MyCompanyName
--	All Rights Reserved
--

on run argv
	try
		my setTimer(listToString(argv, " "))
	on error errmsg
		return errmsg
	end try
end run

on setTimer(dueSearch)
	--on alfred_script(q)
	--set dueSearch to q
	set dueClear to ""
	
	tell application "Due"
		activate
		tell application "System Events"
			keystroke "2" using command down
			delay 0.2
			keystroke "f" using command down
			delay 0.3
			
			-- wait for the text field to become available
			set startTime to current date
			repeat until exists (text field 1 of window "Timers" of application process "Due")
				keystroke "f" using command down
				if (current date) - startTime is greater than 1 then
					error "Could not find text field 1 of window Timers of application process Due"
					exit repeat
				end if
				delay 0.2
			end repeat
			
			tell application process "Due"
				--if text field 1 of window "Reminders" is enabled then
				set value of text field 1 of window "Timers" to dueSearch
				delay 0.2
				-- Arrow Down
				key code 125
				-- Start Timer
				keystroke "s" using command down
				-- Focus text field
				keystroke "f" using command down
				-- Select All
				keystroke "a" using command down
				-- Delete
				key code 51
				-- Switch Back to Reminders Window
				keystroke "1" using command down
				delay 0.5
			end tell
		end tell
	end tell
	--end alfred_script
end setTimer

on listToString(someList, stringDelimiter)
	tell AppleScript
		set oT to text item delimiters
		set text item delimiters to stringDelimiter
		set str to (text items of someList) as string
		set text item delimiters to oT
		return str
	end tell
end listToString
