<?php
include_once('functions.php');
require_once('workflows.php');

$query = $argv[1];
# thanks to http://www.alfredforum.com/topic/1788-prevent-flash-of-no-result
$query = iconv("UTF-8-MAC", "UTF-8", $query);

$w = new Workflows();

# increase memory_limit
if (file_exists($w->data() . "/library.json"))
{
	ini_set('memory_limit', '256M' );
}

//
// Get all_playlists from config
//
$ret = $w->get( 'all_playlists', 'settings.plist' );

if ( $ret == false)
{
	// all_playlists not set
	// set it to default
	$w->set( 'all_playlists', 'false', 'settings.plist' );
	$ret = 'false';
}

if ($ret == 'true')
{
	$all_playlists = true;
}
else
{
	$all_playlists = false;
}

//
// Get is_spotifious_active from config
//
$ret = $w->get( 'is_spotifious_active', 'settings.plist' );

if ( $ret == false)
{
	// is_spotifious_active not set
	// set it to default
	$w->set( 'is_spotifious_active', 'false', 'settings.plist' );
	$ret = 'false';
}

if ($ret == 'true')
{
	$is_spotifious_active = true;
}
else
{
	$is_spotifious_active = false;
}



//
// Get max_results from config
//
$ret = $w->get( 'max_results', 'settings.plist' );

if ( $ret == false)
{
	// all_playlists not set
	// set it to default
	$w->set( 'max_results', '10', 'settings.plist' );
	$ret = '10';
}

$max_results = $ret;
# thanks to http://www.alfredforum.com/topic/1788-prevent-flash-of-no-result
mb_internal_encoding("UTF-8");
if(mb_strlen($query) < 3 || 
	((substr_count( $query, '→' ) == 1) && (strpos("Settings→",$query) !== false))
)
{					
	if ( substr_count( $query, '→' ) == 0 )
	{
		// check for correct configuration
		if (file_exists($w->data() . "/library.json"))
		{
			if($all_playlists == true)
			{
				$w->result( uniqid(), '', "Search for music in all your playlists", "Begin typing to search (at least 3 characters)", './images/allplaylists.png', 'no', '' );
			}
			else
			{
				$w->result( uniqid(), '', "Search for music in your ★ playlist", "Begin typing to search (at least 3 characters)", './images/star.png', 'no', '' );
			}
			
			// get info on current song
			$command_output = exec("osascript track_info.scpt");
	
			if(substr_count( $command_output, '→' ) > 0)
			{
				$results = explode('→', $command_output);
				$currentArtwork = getTrackArtwork($results[4],false);
				$currentArtistArtwork = getArtistArtwork($results[1],false);
				$w->result( uniqid(), '||||playpause|||', "$results[0]", "$results[2] by $results[1]", ($results[3] == 'playing') ? './images/pause.png' : './images/play.png', 'yes', '' );
				$w->result( uniqid(), '', "$results[1]", "More from this artist..", $currentArtistArtwork, 'no', $results[1] );
				$w->result( uniqid(), '', "$results[2]", "More from this album..", $currentArtwork, 'no', $results[2] );
			}
			if (file_exists($w->data() . "/playlists.json"))
			{
				$w->result( uniqid(), '', "Playlists", "Browse by playlist", './images/playlist.png', 'no', 'Playlist→' );
			}	
			$w->result( uniqid(), '', "Artists", "Browse by artist", './images/artists.png', 'no', 'Artist→' );
			$w->result( uniqid(), '', "Albums", "Browse by album", './images/albums.png', 'no', 'Album→' );			
		}
		else
		{
			$w->result( uniqid(), '', "Workflow is not configured, library.json is missing", "Go to settings to install library, please refer to documentation", './images/warning.png', 'no', '' );
		}

		if ($is_spotifious_active == true)
		{
			$spotifious_state = 'enabled';
		}
		else
		{
			$spotifious_state = 'disabled';		
		}
		if ($all_playlists == true)
		{
			$w->result( uniqid(), '', "Settings", "Current: Search Scope=all>, Max Results=" . $max_results . ", Spotifious is " . $spotifious_state, './images/settings.png', 'no', 'Settings→' );
		}
		else
		{
			$w->result( uniqid(), '', "Settings", "Current: Search Scope=★>, Max Results=" . $max_results  . ", Spotifious is " . $spotifious_state, './images/settings.png', 'no', 'Settings→' );
		}	
		
	}
	//
	// Settings
	//
	elseif ( substr_count( $query, '→' ) == 1 )
	{	
		if ($all_playlists == true)
		{
			// argument is csv form: track_uri|album_uri|artist_uri|playlist_uri|spotify_command|query|max_results|other_action
			$w->result( uniqid(), "|||||||" . "disable_all_playlist", "Change Search Scope", "Select to change to ★ playlist only", './images/star_switch.png', 'yes', '' );
		}
		else
		{
			$w->result( uniqid(), "|||||||" . "enable_all_playlist", "Change Search Scope", "Select to change to ALL playlists", './images/allplaylists_switch.png', 'yes', '' );
		}
		$w->result( uniqid(), "|||||||" . "open_spotify_export_app", "Open Spotify App <spotify:app:export>", "Once clipboard contains json data, get back here and use Install or Update library.", './images/app_export.png', 'yes', '' );
		$w->result( uniqid(), "|||||||" . "update_library_json", "Install or Update library", "Make sure the clipboard contains the json data from the Spotify App <spotify:app:export>", './images/update_library.png', 'yes', '' );
		$w->result( uniqid(), '', "Configure Max Number of Results", "Number of results displayed", './images/max_number.png', 'no', 'Settings→MaxResults→' );
		$w->result( uniqid(), "|||||||" . "cache", "Cache All Artworks", "This is recommended to do it before using the player", './images/cache.png', 'yes', '' );
		$w->result( uniqid(), "|||||||" . "clear", "Clear Cached Artworks", "All cached artworks will be deleted", './images/clear.png', 'yes', '' );
		if ($is_spotifious_active == true)
		{
			$w->result( uniqid(), "|||||||" . "disable_spotifiuous", "Disable Spotifious", "Do not display Spotifious in default results", './images/setting_spotifious.png', 'yes', '' );
		}
		else
		{
			$w->result( uniqid(), "|||||||" . "enable_spotifiuous", "Enable Spotifious", "Display Spotifious in default results", './images/setting_spotifious.png', 'yes', '' );
		}
		
	}
} 
else 
{
	////////////
	//
	// NO DELIMITER
	//
	////////////	
	if ( substr_count( $query, '→' ) == 0 )
	{	
		//
		// Search in Playlists
		//
		if (file_exists($w->data() . "/playlists.json"))
		{		
			$json = file_get_contents($w->data() . "/playlists.json");
			$json = json_decode($json,true);
			
			foreach ($json as $key => $val) 
			{				
				if (strpos(strtolower($val),strtolower($query)) !== false)
				{	
					$w->result( "spotify_mini-spotify-playlist-$val", "|||" . $key . "||||", ucfirst($val), "Browse Playlist", './images/playlist.png', 'yes', '' );
				}
			};
		}

		//
		// Search everything
		//
		
		if($all_playlists == false)
		{
			$json = file_get_contents($w->data() . "/library_starred_playlist.json");
		}
		else
		{
			$json = file_get_contents($w->data() . "/library.json");
		}
		$json = json_decode($json,true);
				
		$currentResultNumber = 1;
		foreach ($json as $item) 
		{	
			if($currentResultNumber > $max_results)
				break;			
			if (strpos(strtolower($item['data']['album']['artist']['name']),strtolower($query)) !== false ||
				strpos(strtolower($item['data']['album']['name']),strtolower($query)) !== false ||
				strpos(strtolower($item['data']['name']),strtolower($query)) !== false)
			{				
				// Figure out search rank
				$popularity = $item['data']['popularity'];
				$popularity/=100;
				
				// Convert popularity to stars
				$stars = floor($popularity * 5);
				$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
					
				$subtitle = $item['data']['album']['name'] . " - <alt> play album, <cmd> play artist";
				$subtitle = "$starString $subtitle";
				
				if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name']) == false)
				{					
					$w->result( "spotify_mini-spotify-track" . $item['data']['uri'], $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "|||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri'],true), 'yes', '' );
				}
				$currentResultNumber++;
			}
		};

		$w->result( '', "||||activate (open location \"spotify:search:" . $query . "\")|||", "Search for " . $query . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
		if($is_spotifious_active == true)
		{
			$w->result( '', "|||||" . "$query" . "||", "Search for " . $query . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
		}
	}
	////////////
	//
	// FIRST DELIMITER: Artist→, Album→, Playlist→ or Settings→
	//
	////////////
	elseif ( substr_count( $query, '→' ) == 1 )
	{		
		$words = explode('→', $query);
		
		$kind=$words[0];

		if($kind == "Playlist")
		{
			//
			// Search playlists
			//
			$playlist=$words[1];
			
			if(mb_strlen($playlist) < 3)
			{
				//
				// Display all playlists
				//
				$json = file_get_contents($w->data() . "/playlists.json");
				$json = json_decode($json,true);
				
				foreach ($json as $key => $val) 
				{	
					$r = explode(':', $key);
					$playlist_user = $r[2];
					$w->result( "spotify_mini-spotify-playlist-$val", '', ucfirst($val), "by " . $playlist_user, './images/playlist.png', 'no', "Playlist→" . $val . "→" );
				};
			}
			else
			{
				$json = file_get_contents($w->data() . "/playlists.json");
				$json = json_decode($json,true);
				
				foreach ($json as $key => $val) 
				{
					$r = explode(':', $key);
					$playlist_user = $r[2];
								
					if (strpos(strtolower($val),strtolower($playlist)) !== false ||
						strpos(strtolower($playlist_user),strtolower($playlist)) !== false )
					{	
						$w->result( "spotify_mini-spotify-playlist-$val", '', ucfirst($val), "by " . $playlist_user, './images/playlist.png', 'no', "Playlist→" . $val . "→" );
					}
				};
			}
		} // search by Playlist end	
		elseif($kind == "Artist")
		{
			if($all_playlists == false)
			{
				$json = file_get_contents($w->data() . "/library_starred_playlist.json");
			}
			else
			{
				$json = file_get_contents($w->data() . "/library.json");
			}	
			$json = json_decode($json,true);
			
			//
			// Search artists
			//
			$artist=$words[1];
			
			if(mb_strlen($artist) < 3)
			{
				// display all artists
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
						
					if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name'])) == false)
					{													
						$w->result( "spotify_mini-spotify-artist-" . $item['data']['album']['artist']['name'], '', ucfirst($item['data']['album']['artist']['name']), "Get tracks from this artist", getArtistArtwork($item['data']['album']['artist']['name'],true), 'no', "Artist→" . $item['data']['album']['artist']['name'] . "→" );
						
						$currentResultNumber++;
					}
				};
			}
			else
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
								
					if (strpos(strtolower($item['data']['album']['artist']['name']),strtolower($artist)) !== false)
					{	
						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name'])) == false)
						{									
							$w->result( "spotify_mini-spotify-artist-" . $item['data']['album']['artist']['name'], '', ucfirst($item['data']['album']['artist']['name']), "Get tracks from this artist", getArtistArtwork($item['data']['album']['artist']['name'],true), 'no', "Artist→" . $item['data']['album']['artist']['name'] . "→" );
							
							$currentResultNumber++;
						}
					}			
				};
				$w->result( '', "||||activate (open location \"spotify:search:" . $artist . "\")|||", "Search for " . $artist . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				if($is_spotifious_active == true)
				{
					$w->result( '', "|||||" . "$artist" . "||", "Search for " . $artist . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
				}
			}
		} // search by Album end
		elseif($kind == "Album")
		{
			if($all_playlists == false)
			{
				$json = file_get_contents($w->data() . "/library_starred_playlist.json");
			}
			else
			{
				$json = file_get_contents($w->data() . "/library.json");
			}	
			$json = json_decode($json,true);
		
			//
			// Search albums
			//
			$album=$words[1];
			
			if(mb_strlen($album) < 3)
			{
				// display all artists
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
								
					if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['name'])) == false)
					{						
						$w->result( "spotify_mini-spotify-album" . $item['data']['album']['name'], '', ucfirst($item['data']['album']['name']), "by " . $item['data']['album']['artist']['name'] . " (" . $item['data']['album']['year'] . ")", getTrackArtwork($item['data']['album']['uri'],true), 'no', "Album→" . $item['data']['album']['name'] . "→" );
						
						$currentResultNumber++;
					}
				};
			}
			else
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
		
					if (strpos(strtolower($item['data']['album']['name']),strtolower($album)) !== false)
					{	
						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['name'])) == false)
						{								
							$w->result( "spotify_mini-spotify-album" . $item['data']['album']['name'], '', ucfirst($item['data']['album']['name']), "by " . $item['data']['album']['artist']['name'] . " (" . $item['data']['album']['year'] . ")", getTrackArtwork($item['data']['album']['uri'],true), 'no', "Album→" . $item['data']['album']['name'] . "→" );
							
							$currentResultNumber++;
						}
					}
				};
				$w->result( '', "||||activate (open location \"spotify:search:" . $album . "\")|||", "Search for " . $album . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				if($is_spotifious_active == true)
				{
					$w->result( '', "|||||" . "$album" . "||", "Search for " . $album . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
				}
			}
		} // search by Album end
	}
	////////////
	//
	// SECOND DELIMITER: Artist→the_artist→tracks , Album→the_album→tracks, Playlist→the_playlist→tracks or Settings→MaxResults→max_numbers
	//
	////////////
	elseif ( substr_count( $query, '→' ) == 2 )
	{		
		//
		// Get all songs for selected artist
		//
		
		$words = explode('→', $query);
		
		$kind=$words[0];
		if($kind == "Artist")
		{	
			if($all_playlists == false)
			{
				$json = file_get_contents($w->data() . "/library_starred_playlist.json");
			}
			else
			{
				$json = file_get_contents($w->data() . "/library.json");
			}	
			$json = json_decode($json,true);
			//		
			// display tracks for selected artists
			//
			$artist=$words[1];
			$track=$words[2];
			
			if(mb_strlen($track) < 3)
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;		
					if (strpos(strtolower($item['data']['album']['artist']['name']),strtolower($artist)) !== false)
					{				
						// Figure out search rank
						$popularity = $item['data']['popularity'];
						$popularity/=100;
						
						// Convert popularity to stars
						$stars = floor($popularity * 5);
						$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
							
						$subtitle = $item['data']['album']['name'] . " - <alt> play album, <cmd> play artist";
						$subtitle = "$starString $subtitle";

						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name']) == false)
						{	
							$w->result( "spotify_mini-spotify-track-" . $item['data']['name'], $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "|||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri'],true), 'yes', '' );
						}
						$currentResultNumber++;
					}			
				}
				$w->result( '', "||||activate (open location \"spotify:search:" . $artist . "\")|||", "Search for " . $artist . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				if($is_spotifious_active == true)
				{
					$w->result( '', "|||||" . "$artist" . "||", "Search for " . $artist . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
				}
			}
			else
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
								
					if (strpos(strtolower($item['data']['album']['artist']['name']),strtolower($artist)) !== false &&
						strpos(strtolower($item['data']['name']),strtolower($track)) !== false)
					{				
						// Figure out search rank
						$popularity = $item['data']['popularity'];
						$popularity/=100;
						
						// Convert popularity to stars
						$stars = floor($popularity * 5);
						$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
							
						$subtitle = $item['data']['album']['name'] . " - <alt> play album, <cmd> play artist";
						$subtitle = "$starString $subtitle";

						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name']) == false)
						{								
							$w->result( "spotify_mini-spotify-track-" . $item['data']['name'], $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "|||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri'],true), 'yes', '' );
						}
						$currentResultNumber++;
					}
				};
				$w->result( '', "||||activate (open location \"spotify:search:" . $track . "\")|||", "Search for " . $track . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				if($is_spotifious_active == true)
				{
					$w->result( '', "|||||" . "$track" . "||", "Search for " . $track . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
				}
			}
		}// end of tracks by artist
		elseif($kind == "Album")
		{
			if($all_playlists == false)
			{
				$json = file_get_contents($w->data() . "/library_starred_playlist.json");
			}
			else
			{
				$json = file_get_contents($w->data() . "/library.json");
			}	
			$json = json_decode($json,true);

			//		
			// display tracks for selected album
			//
			$album=$words[1];
			$track=$words[2];
			
			if(mb_strlen($track) < 3)
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
	
					if (strpos(strtolower($item['data']['album']['name']),strtolower($album)) !== false)
					{				
						// Figure out search rank
						$popularity = $item['data']['popularity'];
						$popularity/=100;
						
						// Convert popularity to stars
						$stars = floor($popularity * 5);
						$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
							
						$subtitle = $item['data']['album']['name'] . " - <alt> play album, <cmd> play artist";
						$subtitle = "$starString $subtitle";

						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name']) == false)
						{	
							$w->result( "spotify_mini-spotify-track-" . $item['data']['name'], $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "|||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri'],true), 'yes', '' );
						}
						$currentResultNumber++;
					}			
				}
				$w->result( '', "||||activate (open location \"spotify:search:" . $album . "\")|||", "Search for " . $album . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				if($is_spotifious_active == true)
				{
					$w->result( '', "|||||" . "$album" . "||", "Search for " . $album . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
				}
			}
			else
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
								
					if (strpos(strtolower($item['data']['album']['name']),strtolower($album)) !== false &&
						strpos(strtolower($item['data']['name']),strtolower($track)) !== false)
					{				
						// Figure out search rank
						$popularity = $item['data']['popularity'];
						$popularity/=100;
						
						// Convert popularity to stars
						$stars = floor($popularity * 5);
						$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
							
						$subtitle = $item['data']['album']['name'] . " - <alt> play album, <cmd> play artist";
						$subtitle = "$starString $subtitle";

						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name']) == false)
						{	
							$w->result( "spotify_mini-spotify-track-" . $item['data']['name'], $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "|||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri'],true), 'yes', '' );
						}
						$currentResultNumber++;
					}
				};
				$w->result( '', "||||activate (open location \"spotify:search:" . $track . "\")|||", "Search for " . $track . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				if($is_spotifious_active == true)
				{
					$w->result( '', "|||||" . "$track" . "||", "Search for " . $track . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
				}
			}			
		}// end of tracks by album
		elseif($kind == "Playlist")
		{
			//		
			// display tracks for selected playlist
			//
			$playlist=$words[1];
			$track=$words[2];
			
			// retrieve playlist uri from playlist name
			if(file_exists($w->data() . "/playlists.json"))
			{
				$json = file_get_contents($w->data() . "/playlists.json");
				$json = json_decode($json,true);
				
				$playlist_file = "nonexistant";
				foreach ($json as $key => $val) 
				{
					if (strpos(str_replace(")","\)",str_replace("(","\(",strtolower($val))),strtolower($playlist)) !== false)
					{
						$res = explode(':', $key);
						$playlist_name = $res[4];
						$playlist_user = $res[2];
						$playlist_file = 'playlist_' . $playlist_name . '.json';
						break;
					}
				}
				
				if(file_exists($w->data() . "/" . $playlist_file))
				{
					$json = file_get_contents($w->data() . "/" . $playlist_file);
					$json = json_decode($json,true);	

					$w->result( "spotify_mini-spotify-playlist-$val", "|||" . $key . "||||", ucfirst($val) . " by " . $playlist_user, "Launch Playlist", './images/playlist.png', 'yes', '' );
									
					if(mb_strlen($track) < 3)
					{
						//
						// display all tracks from playlist
						//
						$currentResultNumber = 1;
						foreach ($json as $item) 
						{	
							if($currentResultNumber > $max_results)
								break;
		
							$w->result( "spotify_mini-spotify-" . $playlist . "-" . $item[1], $item[2] . "|||||||", ucfirst($item[0]) . " - " . $item[1], "Play track", getTrackArtwork($item[2],true), 'yes', '' );
							$currentResultNumber++;		
						}
						$w->result( '', "||||activate (open location \"spotify:search:" . $playlist . "\")|||", "Search for " . $playlist . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
						if($is_spotifious_active == true)
						{
							$w->result( '', "|||||" . "$playlist" . "||", "Search for " . $playlist . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
						}

					}
					else
					{
						$currentResultNumber = 1;
						foreach ($json as $item) 
						{	
							if($currentResultNumber > $max_results)
								break;
										
							if (strpos(strtolower($item[1]),strtolower($track)) !== false ||
								strpos(strtolower($item[0]),strtolower($track)) !== false)
							{					
								$w->result( "spotify_mini-spotify-" . $playlist . "-" . $item[1], $item[2] . "|||||||", ucfirst($item[0]) . " - " . $item[1], "Play track", getTrackArtwork($item[2],true), 'yes', '' );
								$currentResultNumber++;
							}	
						};
						$w->result( '', "||||activate (open location \"spotify:search:" . $track . "\")|||", "Search for " . $track . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
						if($is_spotifious_active == true)
						{
							$w->result( '', "|||||" . "$track" . "||", "Search for " . $track . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );	
						}
					}									
				}				
				
			}			
		}// end of tracks by Playlist
		elseif($kind == "Settings")
		{
			//		
			// display tracks for selected album
			//
			$max_results=$words[2];
			
			if(mb_strlen($max_results) == 0)
			{					
				$w->result( uniqid(), '', "Enter the Max Results number (must be greater than 0):", "The number of results has impact on performances", './images/max_number.png', 'no', '' );
			}
			else
			{
				// max results has been set
				if(is_numeric($max_results) == true && $max_results > 0)
				{
					$w->result( '', "||||||$max_results|", "Max Results will be set to <" . $max_results . ">", "Type enter to validate the Max Results", './images/max_number.png', 'yes', '' );
				}
				else
				{
					$w->result( uniqid(), '', "The Max Results value entered is not valid", "Please fix it", './images/warning.png', 'no', '' );

				}
			}			
		}// end of tracks by album
	}
}

echo $w->toxml();

?>