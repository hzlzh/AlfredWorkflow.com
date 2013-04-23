<?php
	require_once('workflows.php');
	
	$w = new Workflows();
	
	ini_set('memory_limit', '512M' );
	
	//
	// Create the library_starred_playlist.json
	//
	if(!file_exists($w->data() . "/library_starred_playlist.json"))
	{
		$array_starred_items = array();
			
		if (file_exists($w->data() . "/library.json"))
		{
			$json = file_get_contents($w->data() . "/library.json");	
			$json = json_decode($json,true);
			
			foreach ($json as $item) 
			{	
				if ( $item['data']['starred'] == true )
				{
					array_push( $array_starred_items, $item );
				}
			}
			$w->write( $array_starred_items, 'library_starred_playlist.json' );
		}
	}

	//
	// Create the playlists.json
	//
	if(!file_exists($w->data() . "/playlists-tmp.json"))
	{
		exec('mdfind -name guistate', $results);
		
		$theUser = "";
		$theGuiStateFile = "";
		foreach ($results as $guistateFile)
		{
			if (strpos($guistateFile,"Spotify/Users") !== false)
			{
				$theGuiStateFile = $guistateFile;
				
				$a = explode('/', trim($theGuiStateFile, '/'));
				$b = explode('-', $a[6]);
				$theUser = $b[0];
				break;
			}
		}

		if($theGuiStateFile != "")
		{
			$json = file_get_contents($theGuiStateFile);	
			$json = json_decode($json,true);
			$res = array();

			if($theUser != "")
			{
				array_push($res,'spotify:user:' . $theUser . ':starred');
			}
			
			foreach ($json['views'] as $view) 
			{					
				array_push( $res, $view['uri'] );
			}
			$w->write( $res, 'playlists-tmp.json' );
		}
	}

	//
	// Create one json file per playlist
	//
	if(file_exists($w->data() . "/playlists-tmp.json"))
	{
		$json = file_get_contents($w->data() . "/playlists-tmp.json");
		$json = json_decode($json,true);
		
		$playlist_array = array();
		
		foreach ($json as $key) 
		{
			//
			// Loop on Playlists
			//	
			$no_match = false;		
			$uri = $key;
			$completeUri = $uri;
			
			$results = explode(':', $uri);
			$playlist_name = $results[4];
			$get_context = stream_context_create(array('http'=>array('timeout'=>5)));
			@$get = file_get_contents('https://embed.spotify.com/?uri=' . $uri, false, $get_context);
		
			$array_playlist_tracks = array();
			
			if(empty($get))
			{
				$no_match = true;
			}
			else
			{
				preg_match_all("'<title>(.*?)</title>'si", $get, $name);
				preg_match_all("'<li class=\"artist \b[^>]*>(.*?)</li>'si", $get, $artists);
				preg_match_all("'<li class=\"track-title \b[^>]*>(.*?)</li>'si", $get, $titles);
				preg_match_all("'<li \b[^>]* data-track=\"(.*?)\" \b[^>]*>'si", $get, $uris);
		
				if($name[1] && $artists[1] && $titles[1] && $uris[1])
				{
					$name = strstr($name[1][0], ' by', true);
					
					$n = 0;
		
					foreach($uris[1] as $uri)
					{
						$artist = $artists[1][$n];
						$title = ltrim(substr($titles[1][$n], strpos($titles[1][$n], ' ')));
						$uri = 'spotify:track:' . $uri;
						
						$item = array ($artist,$title,$uri);
						array_push( $array_playlist_tracks, $item );
		
						$n++;
					}
				}
				else
				{
					$no_match = true;
				}
			}
		
			if($no_match == false)
			{
				$playlist_array[$completeUri] = $name;
				$w->write( $array_playlist_tracks, 'playlist_' . $playlist_name . '.json' );
			}
		};
		
		$w->write( $playlist_array, 'playlists.json' );
		
		unlink($w->data() . "/playlists-tmp.json");	
	}
?>