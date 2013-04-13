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

if (file_exists($w->data() . "/library.json"))
{
	$json = file_get_contents($w->data() . "/library.json");	
	$json = json_decode($json,true);
	
	foreach ($json as $item) 
	{	
		if ( ($all_playlists == false && $item['data']['starred'] == true) ||
			$all_playlists == true )
		{
			getTrackArtwork($item['data']['uri']);
			getArtistArtwork($item['data']['album']['artist']['name']);
			getTrackArtwork($item['data']['album']['uri']);
		}
	};
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