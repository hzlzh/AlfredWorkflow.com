<?php
include_once('functions.php');
require_once('workflows.php');

$query = $argv[1];

$w = new Workflows();

//getTrackArtwork("spotify:track:5zVuwIbBePtNKX1xNr7VXP");

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

if(strlen($query) < 3 || 
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
			$results = explode('→', exec("osascript track_info.scpt"));
			$currentStatus = ($results[3] == 'playing') ? '►' : '❙❙';
			$currentArtwork = getTrackArtwork($results[4]);
			$currentArtistArtwork = getArtistArtwork($results[1]);
			$w->result( uniqid(), '||||playpause||||', "$currentStatus $results[0]", "$results[2] by $results[1]", $currentArtwork, 'yes', '' );
			$w->result( uniqid(), '', "$results[1]", "More from this artist..", (!file_exists($currentArtistArtwork)) ? 'icon.png' : $currentArtistArtwork, 'no', $results[1] );
			$w->result( uniqid(), '', "$results[2]", "More from this album..", (!file_exists($currentArtwork)) ? 'icon.png' : $currentArtwork, 'no', $results[2] );
		
			$w->result( uniqid(), '', "Artists", "Browse by artist", './images/artists.png', 'no', 'Artist→' );
			$w->result( uniqid(), '', "Albums", "Browse by album", './images/albums.png', 'no', 'Album→' );
			if (file_exists($w->data() . "/playlists.json"))
			{
				$w->result( uniqid(), '', "Playlists", "Browse by playlist", './images/playlist.png', 'no', 'Playlist→' );
			}				
		}
		else
		{
			$w->result( uniqid(), '', "Workflow is not configured, library.json is missing", "Go to settings to install library, please refer to documentation", './images/warning.png', 'no', '' );
		}

		if ($all_playlists == true)
		{
			$w->result( uniqid(), '', "Settings", "Current: Search Scope=<All Playlists>, Max Results=" . $max_results, './images/settings.png', 'no', 'Settings→' );
		}
		else
		{
			$w->result( uniqid(), '', "Settings", "Current: Search Scope=<★ Playlist only>, Max Results=" . $max_results, './images/settings.png', 'no', 'Settings→' );
		}	
		
	}
	//
	// Settings
	//
	elseif ( substr_count( $query, '→' ) == 1 )
	{	
		if ($all_playlists == true)
		{
			// argument is csv form: track_uri|album_uri|artist_uri|playlist_uri|spotify_command|query|all_playlists|other_action|max_results
			$w->result( uniqid(), "||||||" . "false" . "||", "Change Search Scope", "Select to change to ★ playlist only", './images/star_switch.png', 'yes', '' );
		}
		else
		{
			$w->result( uniqid(), "||||||" . "true" . "||", "Change Search Scope", "Select to change to ALL playlists", './images/allplaylists_switch.png', 'yes', '' );
		}
		$w->result( uniqid(), '', "Configure max number of results", "You can configure the number of results displayed", './images/max_number.png', 'no', 'Settings→MaxResults→' );
		$w->result( uniqid(), "||||||" . "|cache|", "Cache all artworks for Spotify Mini Player", "This is recommended to do it before using the player", './images/cache.png', 'yes', '' );
		$w->result( uniqid(), "||||||" . "|clear|", "Clear cached artworks for Spotify Mini Player", "Not sure why you would do that", './images/clear.png', 'yes', '' );
		$w->result( uniqid(), "||||||" . "|update_library_json|", "Install or Update library for Spotify Mini Player", "Make sure the clipboard contains the json data from the Spotify App <spotify:app:export>", './images/update_library.png', 'yes', '' );
		
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
		$json = file_get_contents($w->data() . "/library.json");	
		$json = json_decode($json,true);
		
		//
		// Search everything
		//
		$currentResultNumber = 1;
		foreach ($json as $item) 
		{	
			if($currentResultNumber > $max_results)
				break;
			if ( ($all_playlists == false && $item['data']['starred'] == true) ||
				$all_playlists == true )
			{			
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
						
					$subtitle = $item['data']['album']['name'] . " - <alt> open album, <cmd> open artist";
					$subtitle = "$starString $subtitle";
					
					
					$w->result( "spotify_mini-spotify-$query", $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "||||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri']), 'yes', '' );
					
					$currentResultNumber++;
				}
			}
		};

		if (file_exists($w->data() . "/playlists.json"))
		{		
			//
			// Search in Playlists
			//
			$json = file_get_contents($w->data() . "/playlists.json");
			$json = json_decode($json,true);
			
			foreach ($json as $item) 
			{				
				if (strpos(strtolower($item['playlist']['name']),strtolower($query)) !== false)
				{	
					$w->result( "spotify_mini-spotify-playlist-$query", "|||" . $item['playlist']['uri'] . "|||||", ucfirst($item['playlist']['name']), "Launch Playlist", './images/playlist.png', 'yes', '' );
				}
			};
		}

		$w->result( uniqid(), "||||activate (open location \"spotify:search:" . $query . "\")||||", "Search for " . $query . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
		$w->result( uniqid(), "|||||" . "$query" . "|||", "Search for " . $query . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
	}
	////////////
	//
	// FIRST DELIMITER: Artist→, Album→, Playlist→ or Settings→
	//
	////////////
	elseif ( substr_count( $query, '→' ) == 1 )
	{
		$json = file_get_contents($w->data() . "/library.json");	
		$json = json_decode($json,true);
		
		$words = explode('→', $query);
		
		$kind=$words[0];
		
		if($kind == "Artist")
		{
			//
			// Search artists
			//
			$artist=$words[1];
			
			if(strlen($artist) < 3)
			{
				// display all artists
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name'])) == false)
						{													
							$w->result( uniqid(), '', ucfirst($item['data']['album']['artist']['name']), "Get tracks from this artist", getArtistArtwork($item['data']['album']['artist']['name']), 'no', "Artist→" . $item['data']['album']['artist']['name'] . "→" );
							
							$currentResultNumber++;
						}
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
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if (strpos(strtolower($item['data']['album']['artist']['name']),strtolower($artist)) !== false)
						{	
							if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['artist']['name'])) == false)
							{									
								$w->result( "spotify_mini-spotify-artist-$artist", '', ucfirst($item['data']['album']['artist']['name']), "Get tracks from this artist", getArtistArtwork($item['data']['album']['artist']['name']), 'no', "Artist→" . $item['data']['album']['artist']['name'] . "→" );
								
								$currentResultNumber++;
							}
						}
					}	
			
				};
				$w->result( uniqid(), "||||activate (open location \"spotify:search:" . $artist . "\")||||", "Search for " . $artist . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				$w->result( uniqid(), "|||||" . "$artist" . "|||", "Search for " . $artist . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
			}
		} // search by Album end
		elseif($kind == "Album")
		{
			//
			// Search albums
			//
			$album=$words[1];
			
			if(strlen($album) < 3)
			{
				// display all artists
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['name'])) == false)
						{						
							$w->result( uniqid(), '', ucfirst($item['data']['album']['name']), "by " . $item['data']['album']['artist']['name'] . " (" . $item['data']['album']['year'] . ")", getTrackArtwork($item['data']['album']['uri']), 'no', "Album→" . $item['data']['album']['name'] . "→" );
							
							$currentResultNumber++;
						}
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
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if (strpos(strtolower($item['data']['album']['name']),strtolower($album)) !== false)
						{	
							if(checkIfResultAlreadyThere($w->results(),ucfirst($item['data']['album']['name'])) == false)
							{								
								$w->result( "spotify_mini-spotify-album-$album", '', ucfirst($item['data']['album']['name']), "by " . $item['data']['album']['artist']['name'] . " (" . $item['data']['album']['year'] . ")", getTrackArtwork($item['data']['album']['uri']), 'no', "Album→" . $item['data']['album']['name'] . "→" );
								
								$currentResultNumber++;
							}
						}
					}	
			
				};
				$w->result( uniqid(), "||||activate (open location \"spotify:search:" . $album . "\")||||", "Search for " . $album . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				$w->result( uniqid(), "|||||" . "$album" . "|||", "Search for " . $album . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
			}
		} // search by Album end
		elseif($kind == "Playlist")
		{
			//
			// Search playlists
			//
			$playlist=$words[1];
			
			if(strlen($playlist) < 3)
			{
				//
				// Display all playlists
				//
				$json = file_get_contents($w->data() . "/playlists.json");
				$json = json_decode($json,true);
				
				foreach ($json as $item) 
				{	
					$w->result( "spotify_mini-spotify-playlist-$playlist", "|||" . $item['playlist']['uri'] . "|||||", ucfirst($item['playlist']['name']), "Launch Playlist", './images/playlist.png', 'yes', '' );
				};
			}
			else
			{
				$json = file_get_contents($w->data() . "/playlists.json");
				$json = json_decode($json,true);
				
				foreach ($json as $item) 
				{				
					if (strpos(strtolower($item['playlist']['name']),strtolower($playlist)) !== false)
					{	
						$w->result( "spotify_mini-spotify-playlist-$playlist", "|||" . $item['playlist']['uri'] . "|||||", ucfirst($item['playlist']['name']), "Launch Playlist", './images/playlist.png', 'yes', '' );
					}
				};
			}
		} // search by Playlist end
	}
	////////////
	//
	// SECOND DELIMITER: Artist→the_artist→tracks , Album→the_album→tracks or Settings→MaxResults→max_numbers
	//
	////////////
	elseif ( substr_count( $query, '→' ) == 2 )
	{
		$json = file_get_contents($w->data() . "/library.json");	
		$json = json_decode($json,true);
		
		//
		// Get all songs for selected artist
		//
		
		$words = explode('→', $query);
		
		$kind=$words[0];
		if($kind == "Artist")
		{	
			//		
			// display tracks for selected artists
			//
			$artist=$words[1];
			$track=$words[2];
			
			if(strlen($track) < 3)
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if (strpos(strtolower($item['data']['album']['artist']['name']),strtolower($artist)) !== false)
						{				
							// Figure out search rank
							$popularity = $item['data']['popularity'];
							$popularity/=100;
							
							// Convert popularity to stars
							$stars = floor($popularity * 5);
							$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
								
							$subtitle = $item['data']['album']['name'] . " - <alt> open album, <cmd>; open artist";
							$subtitle = "$starString $subtitle";

							$w->result( "spotify_mini-spotify-$query", $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "||||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri']), 'yes', '' );
							
							$currentResultNumber++;
						}			
					};
				}
				$w->result( uniqid(), "||||activate (open location \"spotify:search:" . $artist . "\")||||", "Search for " . $artist . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				$w->result( uniqid(), "|||||" . "$artist" . "|||", "Search for " . $artist . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
			}
			else
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if (strpos(strtolower($item['data']['album']['artist']['name']),strtolower($artist)) !== false &&
							strpos(strtolower($item['data']['name']),strtolower($track)) !== false)
						{				
							// Figure out search rank
							$popularity = $item['data']['popularity'];
							$popularity/=100;
							
							// Convert popularity to stars
							$stars = floor($popularity * 5);
							$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
								
							$subtitle = $item['data']['album']['name'] . " - <alt> open album, <cmd> open artist";
							$subtitle = "$starString $subtitle";
							
							$w->result( "spotify_mini-spotify-$query", $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "||||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri']), 'yes', '' );
							
							$currentResultNumber++;
						}
					}
				};
				$w->result( uniqid(), "||||activate (open location \"spotify:search:" . $track . "\")||||", "Search for " . $track . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				$w->result( uniqid(), "|||||" . "$track" . "|||", "Search for " . $track . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
			}
		}// end of tracks by artist
		elseif($kind == "Album")
		{
			//		
			// display tracks for selected album
			//
			$album=$words[1];
			$track=$words[2];
			
			if(strlen($track) < 3)
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if (strpos(strtolower($item['data']['album']['name']),strtolower($album)) !== false)
						{				
							// Figure out search rank
							$popularity = $item['data']['popularity'];
							$popularity/=100;
							
							// Convert popularity to stars
							$stars = floor($popularity * 5);
							$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
								
							$subtitle = $item['data']['album']['name'] . " - <alt> open album, <cmd> open artist";
							$subtitle = "$starString $subtitle";

							$w->result( "spotify_mini-spotify-$query", $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "||||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri']), 'yes', '' );
							
							$currentResultNumber++;
						}			
					};
				}
				$w->result( uniqid(), "||||activate (open location \"spotify:search:" . $album . "\")||||", "Search for " . $album . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				$w->result( uniqid(), "|||||" . "$album" . "|||", "Search for " . $album . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
			}
			else
			{
				$currentResultNumber = 1;
				foreach ($json as $item) 
				{	
					if($currentResultNumber > $max_results)
						break;
						
					if ( ($all_playlists == false && $item['data']['starred'] == true) ||
						$all_playlists == true )
					{			
						if (strpos(strtolower($item['data']['album']['name']),strtolower($album)) !== false &&
							strpos(strtolower($item['data']['name']),strtolower($track)) !== false)
						{				
							// Figure out search rank
							$popularity = $item['data']['popularity'];
							$popularity/=100;
							
							// Convert popularity to stars
							$stars = floor($popularity * 5);
							$starString = str_repeat("⭑", $stars) . str_repeat("⭒", 5 - $stars);
								
							$subtitle = $item['data']['album']['name'] . " - <alt> open album, <cmd> open artist";
							$subtitle = "$starString $subtitle";

							$w->result( "spotify_mini-spotify-$query", $item['data']['uri'] . "|" . $item['data']['album']['uri'] . "|" . $item['data']['album']['artist']['uri'] . "||||||", ucfirst($item['data']['album']['artist']['name']) . " - " . $item['data']['name'], $subtitle, getTrackArtwork($item['data']['uri']), 'yes', '' );
							
							$currentResultNumber++;
						}
					}
				};
				$w->result( uniqid(), "||||activate (open location \"spotify:search:" . $track . "\")||||", "Search for " . $track . " with Spotify", "This will start a new search in Spotify", 'fileicon:/Applications/Spotify.app', 'yes', '' );
				$w->result( uniqid(), "|||||" . "$track" . "|||", "Search for " . $track . " with Spotifious", "Spotifious workflow must be installed", './images/spotifious.png', 'yes', '' );
			}			
		}// end of tracks by album
		elseif($kind == "Settings")
		{
			//		
			// display tracks for selected album
			//
			$max_results=$words[2];
			
			if(strlen($max_results) == 0)
			{					
				$w->result( uniqid(), '', "Enter the Max Results number (must be greater than 0):", "The number of results has impact on performances", './images/max_number.png', 'no', '' );
			}
			else
			{
				// max results has been set
				if(is_numeric($max_results) == true && $max_results > 0)
				{
					$w->result( uniqid(), "||||||||$max_results", "Max Results will be set to <" . $max_results . ">", "Type enter to validate the Max Results", './images/max_number.png', 'yes', '' );
				}
				else
				{
					$w->result( uniqid(), '', "The Max Results value entered is not valid", "Please correct it", './images/warning.png', 'no', '' );
				}
			}			
		}// end of tracks by album
	}
}

echo $w->toxml();

?>