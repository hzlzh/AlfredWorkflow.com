<?php

function on_error($errno, $errstr, $errfile, $errline) {
	$wf = new Workflows();
	$desc = "($errno) $errstr";

	// show error source if error not raised by user (trigger_error) 
	if($errno != 1024) {
		$desc = array_pop(explode('/', $errfile)) .":$errline - $desc";
	}

	$wf->result(-1, '', "Error found, check message below", $desc, $GLOBALS["icon_path"] . 'AlertStopIcon.icns', false);
	echo $wf->toxml();

	exit($errno);
}

set_error_handler('on_error');

$cache_file = '';
$icon_path = '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/';

function get_filesize($dsize) { 
    if (strlen($dsize) <= 9 && strlen($dsize) >= 7) { 
        $dsize = number_format($dsize / 1048576, 1); 
        return "$dsize MB"; 
    } elseif (strlen($dsize) >= 10) { 
        $dsize = number_format($dsize / 1073741824, 1); 
        return "$dsize GB"; 
    } elseif(strlen($dsize) >= 4) { 
        $dsize = number_format($dsize / 1024, 1); 
        return "$dsize KB"; 
    } else { 
        return "$dsize bytes"; 
    } 
}

function run($dir) {
	$list = load($dir);
    output($dir, $list);
}

function load($dir) {
	$wf = new Workflows();
	$enable_cache = $GLOBALS["enable_cache"];
	$cache_file = $wf->cache() ."/cache-". preg_replace('/[^a-z0-9_-]/i', '', $GLOBALS["url"]);
	$GLOBALS["cache_file"] = $cache_file;

	if($enable_cache) {
		// echo "cache file is $cache_file\n";

		$cache_time = 5 * 60; // 5min
		if(file_exists($cache_file)) {
			$entry = getCachedItem($dir);
			if($entry) return $entry;
		} else {
			file_put_contents($cache_file, serialize(array()));
		}
	}

	$options = array(
	    CURLOPT_CONNECTTIMEOUT=>10,
	    CURLOPT_USERPWD=>$GLOBALS["username"] .':'. $GLOBALS["password"],
	    CURLOPT_FAILONERROR=>true,
	    CURLOPT_CUSTOMREQUEST=>"LIST $dir"
	);
	$lines = explode("\n", $wf->request($GLOBALS["url"], $options));
	// print_r($lines);

	$list = array();
	foreach($lines as $line) {
		if(empty($line)) continue;

	    preg_match_all('/(?P<flag>[dl-])[rwx-]+\s+(?P<contents>\d+).+?(?P<size>\d+)\s+(?P<month>\w+)\s+(?P<date>\d+)\s+(?P<time_or_year>[\d:]+)\s+(?P<name>\S+)/', $line, $out, PREG_SET_ORDER);

	    // ignore invalid line 
	    if(!count($out)) continue;

	    $match = $out[0];
	    $pattern = strpos($match["time_or_year"], ':') === false ? "Y" : "H:i";
	    $timezone = new DatetimeZone($GLOBALS["server_timezone"]);

	    $date = DateTime::createFromFormat("M d $pattern", $match["month"]." ".$match["date"]." ".$match["time_or_year"], $timezone);
	    if($date > date_create("now", $timezone)) {
	    	$date->sub(new DateInterval("P1Y"));
	    }
	    $timestamp = $date->getTimestamp();

	    $keys = array('name', 'size', 'flag');
	    $match = array_intersect_key($match, array_flip($keys));

	    $match["timestamp"] = $timestamp;
	    $match["lastmodifieddate"] = $date->format($GLOBALS["date_format"]);
	    $list["$timestamp-". $match['name']] = $match;
	};

	krsort($list);
	if($enable_cache) {
		$data = unserialize(file_get_contents($cache_file));
		$data[$dir] = array('ts'=>time(), 'list'=>$list);
		file_put_contents($cache_file, serialize($data));
	}
	
	return $list;
}

function getCachedItem($key) {
	if(!$GLOBALS['enable_cache']) return null;

	$data = unserialize(file_get_contents($GLOBALS["cache_file"]));
	if(!array_key_exists($key, $data)) return null;

	$entry = $data[$key];
	$cache_time = 5 * 60; // 5mins
	return time() - $entry['ts'] < $cache_time ? $entry['list']: null;
}

function output($dir, $list) {
	$wf = new Workflows();
	$parent = dirname($dir);

	if($dir != '/') {
		$icon_name = $parent == '/' ? 'HomeFolderIcon.icns' : 'BackwardArrowIcon.icns';
	    $wf->result(0, $parent . ($parent == '/' ? '' : '/'), ".. ($parent)", "Goto parent directory", $GLOBALS["icon_path"] . $icon_name);
	}

    foreach($list as $index=>$entry) {
        $info = pathinfo($entry['name']);
		$path = (substr($dir, -1) == '/' ? $dir : "$dir/") . $entry["name"];

    	// TODO: need to optimize performance in loop
    	if($entry["flag"] == 'd') {
    		$path = "$path/";
    		$icon = $GLOBALS["icon_path"] . (getCachedItem($path) ? 'DropFolderIcon.icns' : 'GenericFolderIcon.icns');
    	} else {
            $icon = array_key_exists('extension', $info) ? "filetype:.". $info['extension'] : $GLOBALS["icon_path"] . 'GenericDocumentIcon.icns';
        }

        $wf->result($index + 1, $path, $entry["name"], ($entry["flag"] == '-' ? get_filesize($entry["size"]) . '. ' : '') ."Last modified: ". $entry["lastmodifieddate"], $icon, $entry["flag"] == '-');
    }

	echo $wf->toxml();
}

$query = ltrim($query);
if(!$query) $query = $root;
if(!$query || $query[0] != '/')  $query = '/'. $query;

run($query);

?>