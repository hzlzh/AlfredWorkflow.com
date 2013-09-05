<?php

/* --------------------------------------------------------
	Extension:	What’s on 6music
	Author: 	Matt Sephton http://www.gingerbeardman.com
	Usage:		6music
	Updated:	2013-04-25
----------------------------------------------------------- */

date_default_timezone_set("Europe/London");

define("SECOND", 1);
define("MINUTE", 60 * SECOND);
define("HOUR", 60 * MINUTE);
define("DAY", 24 * HOUR);
define("MONTH", 30 * DAY);

$epoch = time();

$json = file_get_contents("http://polling.bbc.co.uk/radio/realtime/bbc_6music.jsonp?cachebash=$epoch");
$json = str_replace(array('realtimeCallback(', ')'), '', $json);

$np = json_decode( $json, true );

$id = $np['realtime']['musicbrainz_artist']['id'];
$start = $np['realtime']['start'];
$end = $np['realtime']['end'];
$artist = tidy($np['realtime']['artist']);
$song = tidy($np['realtime']['title']);

function tidy($str) {
	// return str_replace("'", "’", htmlspecialchars($str));
	return str_replace("'", "’", $str);
}

$img = "http://static.bbci.co.uk/music/images/artists/126x71/$id.jpg";

$timestamp = relativeTime($start, $end);

$growlnotifyinstalled = shell_exec("command -v /usr/local/bin/growlnotify >/dev/null 2>&1 || { echo 'nogrowlnotify'; exit 1; }");

$ql = '“';
$qr = '”';

$msg = "$ql$song$qr\n$artist\n\n$timestamp";

$pngs = glob('*.png');
$icon = getcwd().'/'.$pngs[0];

// $growlnotifyinstalled = '';	//disable growlnotify
	
if ($growlnotifyinstalled) {
	shell_exec("/usr/local/bin/growlnotify --image \"$icon\" -m \"by $artist\n\n$timestamp\" -t \"$ql$song$qr\"");
	
	$cmd[] = "growlnotify";
	$cms[] = "-n Alfred";
	$cms[] = "-I '$icon'";
	$cmd[] = "-m 'by $artist\n\n$timestamp'";
	$cmd[] = "-t '$song'";
	$cmd[] = ";";
	
	$shell = implode(' ', $cmd);
	
	// echo "$shell";
	
	system($shell);
} else {
	echo str_replace("\n\n","\n\n",$msg);
}

function relativeTime($time_start, $time_end) {
	
	if (time() < $time_end) {
		$delta = time() - $time_start;
		$end = "started ";
	} else {
		$end = "finished ";
		$delta = time() - $time_end;
	}

	if ($delta < 1 * MINUTE) {
		// return $delta == 1 ? "one second ago" : $delta . " seconds ago";
		return $end . "less than a minute ago";
	}
	if ($delta < 2 * MINUTE) {
		return $end . "a minute ago";
	}
	if ($delta < 45 * MINUTE) {
		return $end . floor($delta / MINUTE) . " minutes ago";
	}
	if ($delta < 90 * MINUTE) {
		return $end . "an hour ago";
	}
	if ($delta < 24 * HOUR) {
		return floor($delta / HOUR) . " hours ago";
	}
	if ($delta < 48 * HOUR) {
		return $end . "yesterday";
	}
	if ($delta < 30 * DAY) {
		return $end . floor($delta / DAY) . " days ago";
	}
	if ($delta < 12 * MONTH) {
		$months = floor($delta / DAY / 30);
		return $end . $months <= 1 ? "one month ago" : $months . " months ago";
	} else {
		$years = floor($delta / DAY / 365);
		return $end . $years <= 1 ? "one year ago" : $years . " years ago";
	}
}

?>