<?php
include_once('functions.php');
require_once('workflows.php');

$w = new Workflows();

$ret = $w->get( 'all_playlists', 'settings.plist' );
if ($ret == 'true')
{
	$all_playlists = true;
}
else
{
	$all_playlists = false;
}

# increase memory_limit
ini_set('memory_limit', '512M' );
	
if (file_exists($w->data() . "/library.json"))
{

	$json = file_get_contents($w->data() . "/library.json");	
	$json = json_decode($json,true);
	
	foreach ($json as $item) 
	{	
		if ( ($all_playlists == false && $item['data']['starred'] == true) ||
			$all_playlists == true )
		{
			getTrackArtwork($item['data']['uri'],true);
			getArtistArtwork($item['data']['album']['artist']['name'],true);
			getTrackArtwork($item['data']['album']['uri'],true);
		}
	};
}

//		
// playlists
//

// retrieve playlist uri from playlist name
if(file_exists($w->data() . "/playlists.json"))
{
	$json = file_get_contents($w->data() . "/playlists.json");
	$json = json_decode($json,true);
	
	$playlist_file = "nonexistant";
	foreach ($json as $key => $val) 
	{
		$res = explode(':', $key);
		$playlist_name = $res[4];
		$playlist_file = 'playlist_' . $playlist_name . '.json';
		
		if(file_exists($w->data() . "/" . $playlist_file))
		{
			$json_playlist = file_get_contents($w->data() . "/" . $playlist_file);
			$json_playlist = json_decode($json_playlist,true);	
				
			foreach ($json_playlist as $item) 
			{	
				getTrackArtwork($item[2],true);
			}						
		}	
	}
}			


if($all_playlists == true)
{
	echo "All Artworks for all playlists were cached";
}
else
{
	echo "All Artworks for ★ playlist were cached";
}
?>