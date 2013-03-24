-- I don't know AppleScript - copy pasted some code from https://getsatisfaction.com/alfredapp/topics/searching_through_nested_menu_items

on run argv
	tell application "System Events"
		set _app to item 1 of (every process whose frontmost is true)
	end tell


	tell application "System Events"
		tell _app
			set menuExists to menu bar 1 exists

			if (menuExists) then set menustuff to entire contents of menu bar 1
			try
				|| of menustuff -- Deliberate error.
			on error stuff -- Get the error message
			end try

			return stuff
		end tell
	end tell
end run
