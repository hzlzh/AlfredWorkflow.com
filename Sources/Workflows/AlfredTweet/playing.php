<?php

require_once('alfredtweet.php');
require_once('workflows.php');

$w = new Workflows();

// Array of all supported players
$supported_players = array(
	'iTunes',
	'Ecoute',
	'Rdio',
	'Spotify'
);

$results = array();

$running_players = check_running( $supported_players );

if ( ! empty( $running_players ) ):							// players running

	$players_playing = check_playing( $running_players );

	if ( ! empty( $players_playing ) ):						//players are playing

		$tracks = get_tracks( $players_playing );

		foreach( $tracks as $track ):
			$w->result(
				time(),
				'Now playing '.$track['track']. ' on album '.$track['album']. ' by '.$track['artist'].' in '.$track['player'].' #alfredtweet.',
				$track['player'].': '.$track['track'].' by '.$track['artist'],
				'Now playing '.$track['track']. ' on album '.$track['album']. ' by '.$track['artist'].' in '.$track['player'].' #alfredtweet.',
				'icon.png'
			);
		endforeach;

	else:													// no players are playing

		$w->result(
			time(),
			'',
			'No players playing',
			'No players are currently playing tracks',
			'icon.png',
			'no'
		);

	endif;

else:														// no players running

	$w->result(
		time(),
		'',
		'No players running',
		'No players are currently running',
		'icon.png',
		'no'
	);

endif;

echo $w->toxml();


/**
* Description:
* Accepts an array of currently supported players and then checks
* to see which players are actually running.
*
* @param $players - an array of supported players
* @return array - an array of players that are running
*/
function check_running( $players ) {
	$running = array();
	foreach( $players as $player ):
		$state = exec('osascript -e \'tell application "System Events" to count every process whose name is "'.$player.'"\'');
		if ( $state == 1 ):
			array_push( $running, $player );
		endif;
	endforeach;
	return $running;
}

/**
* Description:
* Accepts an array of currently running players and checks to
* see if they are playing a track.
*
* @param $players - araray of currently running players
* @return array - an array of players who are currently
*			playing a track. Hopefully only 1.
*/
function check_playing( $players ) {
	$playing = array();
	foreach( $players as $player ):
		$state = `osascript -e 'tell application "$player" to return player state'`;
		if ( strtolower( trim( $state ) ) == 'playing' || $state == 2 ):
			array_push( $playing, $player );
		endif;
	endforeach;
	return $playing;
}

/**
* Description
* Accepts a player name as an argument and reads the values
* of the track name and artist for the currently playing track
* of that player
*
* @param $player - name of the player to read data from
* @return array - array of track name and artist for that player
*/
function get_tracks( $players )
{
	$tracks = array();
	foreach( $players as $player ):
		$track 	= `osascript -e 'tell application "$player" to return name of current track'`;
		$artist = `osascript -e 'tell application "$player" to return artist of current track'`;
		$album  = `osascript -e 'tell application "$player" to return album of current track'`;

		$track  = str_replace("\n", "", $track);
		$artist = str_replace("\n", "", $artist);
		$album  = str_replace("\n", "", $album);
		array_push( $tracks,
			array(
				'track'  => utf8_encode( htmlentities( $track ) ),
				'artist' => utf8_encode( htmlentities( $artist ) ),
				'album'  => utf8_encode( htmlentities( $album ) ),
				'player' => utf8_encode( htmlentities( $player ) )
			)
		);
	endforeach;
	return $tracks;
}