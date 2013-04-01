<?php
require_once __DIR__ . '/vendor/autoload.php';

use Alfred\Workflow;
use Guzzle\Http\Client;

$wf = new Workflow('com.ryanparman.workflow.packagist');
$http = new Client();

$int = 0;
$query = isset($argv[1]) ? $argv[1] : "{query}";

$request = $http->get("https://packagist.org/search.json?q=" . urlencode($query));
$response = $request->send()->json();

foreach ($response['results'] as $result)
{
	$int++;
	$wf->result(array(
		'uid' => $result['name'] . time(),
		'arg' => $result['url'],
		'title' => $result['name'],
		'subtitle' => $result['description'],
		'icon' => __DIR__ . '/icon.png',
		'valid' => 'yes',
		'autocomplete' => 'autocomplete'
	));
}

if (count($wf->results) === 0)
{
	$wf->result(array(
		'uid' => 'none',
		'arg' => $query,
		'title' => 'No results',
		'subtitle' => 'No results found.',
		'icon' => __DIR__ . '/icon.png',
		'valid' => 'no',
	));
}

echo $wf->toXML();
