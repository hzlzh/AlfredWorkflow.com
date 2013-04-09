on run theQuery
	
	tell application "Finder"
		
		try
			set targetFolder to (folder of front window as alias)
		on error
			set targetFolder to (path to desktop folder)
		end try
		
		set targetPath to quoted form of (the POSIX path of targetFolder)
		
		if (theQuery as string) is not "" then
			set theCommand to "cd " & targetPath & " && " & (theQuery as string)
		else
			set theCommand to "cd " & targetPath
		end if
		
	end tell
	
	tell application "Terminal"
		activate
		do script theCommand
	end tell
	
end run