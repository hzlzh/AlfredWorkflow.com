property isiTunesRunning : false
property subCommand : ""
property lyricContent : ""

on run argv    
    tell application "System Events"
        if (count of (every process whose bundle identifier is "com.apple.iTunes")) <= 0 then
            return "1,iTunes is not running."
        end if
    end tell

    tell application "iTunes"
        if player state is not playing then
            return "1,iTunes is not playing."
        end if

        set argv_count to length of argv

        if argv_count = 0 then
            set subCommand to "playing"
        else
            set subCommand to item 1 of argv as text
        end if

        if subCommand = "lyric" then
            if argv_count < 2 then
                return "1, lyric is empty"
            end if
            set lyricContent to item 2 of argv as text
        end if

        set track_id to id of the current track as text
        set track_title to name of the current track as text
        set track_artist to artist of the current track as text
        if subCommand = "lyric" then
            set lyrics of the current track to lyricContent
        end if
        return "0," & track_artist & "," & track_title
    end tell
end run
    