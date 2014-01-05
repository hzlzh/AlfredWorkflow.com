<?php

require('workflows.php');
$w = new Workflows();
$apikey = $w->get('apikey', 'settings.plist');
$mode = $argv[1];
$query = $argv[2];
$query = str_replace(' ', '+', $query);

$id;
$operation;

if (!$apikey) {
	$w->result('', '', 'Error', 'API key has not been set yet. Set it with the command \'apikey\'.', 'icons/error.png');
} else {
	if (strpos($query, 'id:') === 0) {
		$queryArray = explode(":", $query);
		$id = $queryArray[1];
		$operation = $queryArray[2];
		
		switch ($operation) {
			case 'summary':
				show_summary();
				break;
			case 'epguide':
				show_epguide();
				break;
			case 'cast':
				show_cast();
				break;
		}
	} else {
		switch($mode) {
			case 'trends':
				show_trends();
				break;
			case 'shows':
				search_shows();
				break;
		}
	}
}

echo $w->toxml();

/**
 * List all trending shows
 */
function show_trends() {
	global $apikey, $w;
	$url = "http://api.trakt.tv/shows/trending.json/$apikey";
	$shows = $w->request($url);
	$shows = json_decode($shows);
	
	if (is_valid($shows)) {
		print_shows($shows);
	}
}

/**
 * Search for shows
 */
function search_shows() {
	global $apikey, $w, $query;
	$url = "http://api.trakt.tv/search/shows.json/$apikey?query=$query";
	$w->write($url, 'debug.txt');
	$shows = $w->request($url);
	$shows = json_decode($shows);
	
	if (is_valid($shows)) {
		print_shows($shows);
				
		if (count($w->results()) == 0) {
			$w->result( 'info', '', 'No results', 'Please widen your search.', 'icons/info.png', 'no');
		}
	}
}

/**
 * Display a show summary
 */
function show_summary() {
	global $apikey, $w, $id;
	$url = "http://api.trakt.tv/show/summary.json/$apikey/$id/extended";
	$show = $w->request($url);
	$show = json_decode($show);
	
	if (is_valid($show)) {
		$count = count_episodes($show);
		$maincast = get_main_cast($show);
		$latestEp = get_latest_episode($show);
		$trailer = str_replace(' ', '+', $show->title.' trailer');
		
		$w->result('summary', '', $show->title.' ('.$show->year.')', 'Runtime: '.$show->runtime.'min, Rating: '.$show->ratings->percentage.'%', 'icon.png');
		if (isset($latestEp)) {
			$w->result('epguide', $latestEp->url, 'Latest Episode: '.$latestEp->season.'x'.sprintf("%02d", $latestEp->episode).': '.$latestEp->title, 'Aired: '.explode("T", $latestEp->first_aired_iso)[0].', Rating: '.$latestEp->ratings->percentage.'%', 'icons/latest.png');
		}
		if ($count[0] > 0) {
			$specials;
			if ($count[1] > 0) {
				$specials = ' (Plus '.$count[1].' Special Episodes)';
			}
			$w->result('summary', '', 'Show Episode List ...', 'Total Episodes: '.$count[0].$specials, 'icons/episodes.png', 'no', 'id:'.$show->tvdb_id.':epguide');
		}
		if (isset($maincast)) {
			$w->result('summary', '', 'Show Cast ...', $maincast.', ...', 'icons/actors.png', 'no', 'id:'.$show->tvdb_id.':cast');
		}
		$w->result('summary', '', 'Network: '.$show->network.', Status: '.$show->status, 'Air Day: '.$show->air_day.', Air Time: '.$show->air_time, 'icons/network.png');
		$w->result('summary', '', $show->stats->watchers.' Watchers, '.$show->stats->plays.' Plays, '.$show->stats->scrobbles.' Scrobbles', 'Stats', 'icons/stats.png');
		$w->result('summary', $show->url, 'View on trakt.tv', '', 'icons/external.png');
		$w->result('summary', "http://www.imdb.com/title/$show->imdb_id/", 'View on IMDB', '', 'icons/external.png');
		$w->result('summary', "https://www.youtube.com/results?search_query=$trailer", 'Search a trailer on YouTube', '', 'icons/external.png');
	}
}

/**
 * Count episodes
 */
function count_episodes($show) {
	$counts = array();
	$normalCnt = 0;
	$specialCnt = 0;
	foreach($show->seasons as $season):
		if ($season->season > 0) {
			foreach($season->episodes as $episode):
				$normalCnt++;
			endforeach;
		} else {
			foreach($season->episodes as $episode):
				$specialCnt++;
			endforeach;
		}
	endforeach;
	array_push($counts, $normalCnt);
	array_push($counts, $specialCnt);
	return $counts;
}

/**
 * Find the latest episode
 */
function get_latest_episode($show) {
	date_default_timezone_set('UTC');
	$today = new DateTime("now");
	$latestEpisode;
	$diff = 2147483647;
	foreach($show->seasons as $season):
		if ($season->season > 0) {
			foreach($season->episodes as $episode):
				if (!isset($episode->first_aired_iso)) {
					continue;
				}
				$epdate = new DateTime(explode("T", $episode->first_aired_iso)[0]);
				$interval = $today->diff($epdate);
				// only continue if interval is negative (in the past)
				if ($interval->invert == 1 && $interval->days <= $diff) {
					$diff = $interval->days;
					$latestEpisode = $episode;
				}
			endforeach;
		}
	endforeach;
	if (isset($latestEpisode)) {
		return $latestEpisode;
	}
}

/**
 * Show the epguide of the current show
 */
function show_epguide() {
	global $apikey, $w, $id;
	$url = "http://api.trakt.tv/show/summary.json/$apikey/$id/extended";
	$show = $w->request($url);
	$show = json_decode($show);
	
	if (is_valid($show)) {
		$w->result('epguide', '', 'Back ...', '', 'icons/back.png', 'no', 'id:'.$id.':summary');
		foreach($show->seasons as $season):
			foreach($season->episodes as $episode):
				$w->result('epguide', $episode->url, $season->season.'x'.sprintf("%02d", $episode->episode).': '.$episode->title, 'Aired: '.explode("T", $episode->first_aired_iso)[0].', Rating: '.$episode->ratings->percentage.'%', 'icons/episode.png');
			endforeach;
		endforeach;
	}
	$w->sortresults('title', false);
}

/**
 * Get a list of top 2 cast
 */
function get_main_cast($show) {
	$result = array();
	$cnt = 0;
	foreach($show->people->actors as $actor):
		if ($cnt < 2) {
			array_push($result, $actor->character.' ('.$actor->name.')');
			$cnt++;
		}
	endforeach;
	
	if (!empty($result)) {
		return implode(", ", $result);
	}
}

/**
 * Display the series cast
 */
function show_cast() {
	global $apikey, $w, $id;
	$url = "http://api.trakt.tv/show/summary.json/$apikey/$id/extended";
	$show = $w->request($url);
	$show = json_decode($show);
	
	if (is_valid($show)) {
		$w->result('cast', '', 'Back ...', '', 'icons/back.png', 'no', 'id:'.$id.':summary');
		foreach($show->people->actors as $actor):
			$w->result('cast', '', $actor->character, $actor->name, 'icons/actor.png', 'no');
		endforeach;
	}
}

/**
 * Print the specified shows.
 */
function print_shows($shows) {
	global $w;
	foreach($shows as $show):
		$w->result('show', $show->tvdb_id, $show->title, 'Rating: '.$show->ratings->percentage.'% | Year: '.$show->year.' | Network: '.$show->network.' | Genres: '.implode(", ", $show->genres), 'icon.png', 'no', 'id:'.$show->tvdb_id.':summary');
	endforeach;
}

/**
 * Check if the specified json is valid.
 *
 * @param $json - the json that should be checked
 * @return bool - true in case the json is valid, false otherwise
 */
function is_valid($json) {
	global $w;
	if (isset($json->status) && $json->status == 'failure') {
		$w->result('error', '', 'Error', $json->error, 'icons/error.png', 'no');
		return false;
	}
	return true;
}

?>