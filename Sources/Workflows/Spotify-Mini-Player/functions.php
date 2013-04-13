<?php
// Almost all this code is from Spoticious workflow (http://www.alfredforum.com/topic/1644-spotifious-a-natural-spotify-controller-for-alfred/)
// Thanks citelao https://github.com/citelao/Spotify-for-Alfred
require_once('workflows.php');


function checkIfResultAlreadyThere($results,$title) {
	foreach($results as $result) {
		if($result[title]) {
			if($result[title] == $title) {
				return true;
			}
		}	
	}
	return false;
}

function getTrackArtwork($spotifyURL) {
	$hrefs = explode(':', $spotifyURL);
	$w = new Workflows();

	if ( !file_exists( $w->data() . "/artwork" ) ):
		exec("mkdir '".$w->data()."/artwork'");
	endif;
				
	$currentArtwork = $w->data() . "/artwork/$hrefs[2].png";
	
	
	if (!file_exists($currentArtwork)) {
		$artwork = getTrackArtworkURL($hrefs[1], $hrefs[2]);
		// if return 0, it is a 404 error, no need to fetch
		if (!empty($artwork) || (is_numeric($artwork) && $artwork != 0)) {
			$fp = fopen ($currentArtwork, 'w+');
			$options = array(
			CURLOPT_FILE =>	$fp	
			);		
			$w->request( "$artwork", $options );
		}
	}
	if(is_numeric($artwork) && $artwork == 0)
	{
		return "images/albums.png";
	}
	else
	{
		return $currentArtwork;
	}
}

function getArtistArtwork($artist) {
	$parsedArtist = urlencode($artist);
	$w = new Workflows();

	if ( !file_exists( $w->data() . "/artwork" ) ):
		exec("mkdir '".$w->data()."/artwork'");
	endif;
		
	$currentArtwork = $w->data() . "/artwork/$parsedArtist.png";
	
	if (!file_exists($currentArtwork)) {
		$artwork = getArtistArtworkURL($artist);
		// if return 0, it is a 404 error, no need to fetch
		if (!empty($artwork) || (is_numeric($artwork) && $artwork != 0)) {
			$fp = fopen ($currentArtwork, 'w+');
			$options = array(
			CURLOPT_FILE =>	$fp	
			);		
			$w->request( "$artwork", $options );
		}
	}
	
	if(is_numeric($artwork) && $artwork == 0)
	{
		return "images/albums.png";
	}
	else
	{
		return $currentArtwork;
	}
}

function getTrackArtworkURL($type, $id)
{
	$w = new Workflows();
	$html = $w->request( "http://open.spotify.com/$type/$id" );
	
	if (!empty($html)) {
	 	preg_match_all('/.*?og:image.*?content="(.*?)">.*?/is', $html, $m);
	 	return (isset($m[1][0])) ? $m[1][0] : 0;
	}
	
	return 0;
}

function getArtistArtworkURL($artist) {
	$parsedArtist = urlencode($artist);
	$w = new Workflows();
	$html = $w->request( "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&api_key=49d58890a60114e8fdfc63cbcf75d6c5&artist=$parsedArtist&format=json");
	$json = json_decode($html, true);
	
	return $json[artist][image][1]['#text'];
}

?>