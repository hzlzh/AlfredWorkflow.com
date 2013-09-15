<?php
require_once __DIR__ . '/vendor/autoload.php';

use Alfred\Workflow;

$wf = new Workflow('com.ryanparman.workflow.manpages');

$int = 0;
$query = isset($argv[1]) ? $argv[1] : "{query}";
$query = stripslashes($query);

$pieces = explode(' ', $query);
$command = array_shift($pieces);
$args = implode('+', $pieces);

$url = "http://www.explainshell.com/explain/${command}";
if ($args)
{
	$url .= "?args=${args}";
}

$wf->result(array(
	'uid' => time(),
	'arg' => $url,
	'title' => "Explain command for `${command}`",
	'subtitle' => '$ ' . $query,
	'icon' => __DIR__ . '/icon.png',
	'valid' => 'yes',
));

echo $wf->toXML();
