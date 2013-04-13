<?php
require_once('workflows.php');
$w = new Workflows();

$value = $argv[1];

if($value == "true")
{
	$w->set( 'all_playlists', 'true', 'settings.plist' );
	echo "Search scope set to all playlists";
}
else
{
	$w->set( 'all_playlists', 'false', 'settings.plist' );
	echo "Search scope set to starred playlist";
}
?>