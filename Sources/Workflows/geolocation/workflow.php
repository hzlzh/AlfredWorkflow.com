<?php
require_once __DIR__ . '/vendor/autoload.php';

use Alfred\Workflow;
use Guzzle\Http\Client;

$wf = new Workflow('com.ryanparman.workflow.geo');
$http = new Client();

$int = 0;
$query = $argv[1];

$request = $http->get("http://freegeoip.net/json/" . urlencode($query));
$r = $request->send()->json();

extract($r);

$wf->result(array(
	'uid' => 'geocity' . time(),
	'arg' => "${city}, ${region_name}, ${country_name}",
	'title' => "${city}, ${region_name}, ${country_name}",
	'subtitle' => "Data for ${ip}",
	'icon' => __DIR__ . '/icon.png',
	'valid' => 'no',
	'autocomplete' => $ip
));

$wf->result(array(
	'uid' => 'geolatlong' . time(),
	'arg' => "${latitude},${longitude}",
	'title' => "Lat/Long: ${latitude},${longitude}",
	'subtitle' => "Copy to clipboard",
	'icon' => __DIR__ . '/icon.png',
	'valid' => 'yes',
));

$wf->result(array(
	'uid' => 'geoip' . time(),
	'arg' => $ip,
	'title' => "Public IP: ${ip}",
	'subtitle' => "Copy to clipboard",
	'icon' => __DIR__ . '/icon.png',
	'valid' => 'yes',
));

$wf->result(array(
	'uid' => 'geomap' . time(),
	'arg' => "https://maps.google.com/maps?t=v&z=12&ll=${latitude},${longitude}",
	'title' => "Show map of ${latitude},${longitude}",
	'subtitle' => "Open in Google Maps",
	'icon' => __DIR__ . '/icon.png',
	'valid' => 'yes',
));

echo $wf->toXML();
