<?php
require_once __DIR__ . '/vendor/autoload.php';

use Alfred\Workflow;
use Skyzyx\Components\Mimetypes\Mimetypes;

$bundle_id = 'com.ryanparman.workflow.mime';
$wf = new Workflow($bundle_id);

$int = 0;
$query = $argv[1];
$mimes = Mimetypes::getInstance()->getMimeTypes();
$extensions = array_keys($mimes);

$matching_extensions = array_filter($extensions, function($extension) use ($query, $mimes, $wf, &$int)
{
	$int++;
	if (preg_match('/' . $query . '/i', $extension))
	{
		$wf->result(array(
			'uid' => "${extension}-${query}-${int}",
			'arg' => $mimes[$extension],
			'title' => $extension . ': ' . $mimes[$extension],
			'subtitle' => 'Copy to clipboard',
			'icon' => __DIR__ . '/icon.png',
			// 'valid' => 'no',
			// 'autocomplete' => $ip
		));
		return true;
	}
	return false;
});

if (count($matching_extensions) === 0)
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
