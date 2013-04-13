#!/bin/ksh 

QUERY="$1"
TYPE="$2"

# query is csv form: track_uri|album_uri|artist_uri|playlist_uri|spotify_command|all_playlists|other_action|max_results

track_uri=$(echo "${QUERY}" | cut -f1 -d"|")
album_uri=$(echo "${QUERY}" | cut -f2 -d"|")
artist_uri=$(echo "${QUERY}" | cut -f3 -d"|")
playlist_uri=$(echo "${QUERY}" | cut -f4 -d"|")
spotify_command=$(echo "${QUERY}" | cut -f5 -d"|")
original_query=$(echo "${QUERY}" | cut -f6 -d"|")
all_playlists=$(echo "${QUERY}" | cut -f7 -d"|")
other_action=$(echo "${QUERY}" | cut -f8 -d"|")
max_results=$(echo "${QUERY}" | cut -f9 -d"|")

if [ "${TYPE}" = "TRACK" ]
then
	applescript_command="open location \"${track_uri}\""
elif [ "${TYPE}" = "ALBUM" ]
then
	applescript_command="activate (open location \"${album_uri}\")"
else
	applescript_command="activate (open location \"${artist_uri}\")"
fi

# playlist
if [ "-${playlist_uri}-" != "--" ]
then
osascript <<EOT
-- Make sure we have the spotify-application on front and in focus
tell application "Spotify"
	activate
end tell

open location "${playlist_uri}"

-- Now navigate to the song we want to play and play it
tell application "System Events"
	delay (1)
	-- One times tabulator = move selection to the songs list
	key code 48
	-- Wait for a while the spotify app to catch up
	delay (2)
	-- enter key = play selected song
	key code 36
end tell
EOT
elif [ "-${spotify_command}-" != "--" ]
then
osascript <<EOT
tell application "Spotify"
	${spotify_command}
end tell
EOT
elif [ "-${all_playlists}-" != "--" ]
then
php -f set_all_playlists.php -- "${all_playlists}"
elif [ "-${max_results}-" != "--" ]
then
php -f set_max_results.php -- "${max_results}"
elif [ "-${other_action}-" != "--" ]
then
	if [ "${other_action}" == "cache" ]
	then
		php -f download_all_artworks.php	
	elif [ "${other_action}" == "clear" ]
	then
		php -f clear.php
	else
		php -f update_library.php
	fi 
elif [ "-${original_query}-" != "--" ]
then
osascript <<EOT
tell application "Alfred 2" to search "spot ${original_query}"
EOT
else
osascript <<EOT
tell application "Spotify"
	${applescript_command}
end tell
EOT
fi
