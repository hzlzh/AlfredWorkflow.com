on run argv
	set scpt to (run script " 
	tell application \"System Events\"
		set _app to item 1 of (every process whose frontmost is true)
	end tell

	tell application \"System Events\" 
		tell _app 
			--Perform Sample Action (show About) 
			tell menu item " & item 1 of argv & " of menu bar 1
				if (it exists) then perform action \"AXPress\"
			end tell 
		end tell 
	end tell")
end run

