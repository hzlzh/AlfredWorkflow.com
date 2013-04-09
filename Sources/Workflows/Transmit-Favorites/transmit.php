<?php

// Include CFPropertyList library
require('CFPropertyList.php');


// Main configuration
$inQuery = $argv[1] ?: '';
$root = exec('printf $HOME').'/Library/Application Support/Transmit/Metadata/';
$rootPreferences = exec('printf $HOME').'/Library/Preferences/com.panic.Transmit.plist';
$reRowQuery = '/'.preg_quote($inQuery).'/i';
$reValidName = '/\.favoriteMetadata$/';
$results = array();
$excludeResults = array();
$defaultPorts = array(
	'FTP' => ':21',
	'SFTP' => ':22',
	'HTTP' => ':80',
	'HTTPS' => ':443');


// Find history elements
if (file_exists($rootPreferences))
{
	$pList = new CFPropertyList($rootPreferences);
	$data = $pList->toArray();

	$fName = tempnam('/tmp', 'tm-');
	file_put_contents($fName, $data['FavoriteCollections']);

	$pList = new CFPropertyList($fName);

	$matchHistory = false;

	$data = $pList->toArray();
	foreach ($data['$objects'] AS $i => $value)
	{
		if ($matchHistory === false)
		{
			if ($value == 'History')
				$matchHistory = true;
		} elseif ($matchHistory === true)
		{
			if ($value['NS.objects'])
				$matchHistory = count($value['NS.objects']);
		} elseif ($matchHistory > 0)
		{
			if (is_array($value) && isset($value['NS.string']) && preg_match('/^[\dA-Fa-f]{8}\-[\dA-Fa-f]{4}\-[\dA-Fa-f]{4}\-[\dA-Fa-f]{4}\-[\dA-Fa-f]{12}$/', $value['NS.string']))
				$excludeResults[$value['NS.string']] = $matchHistory--;
		} else
			break;
	}

	unlink($fName);
}


// Reading Transmit Metadata files
if (($dp = @opendir($root)) !== false)
{
	while ($fName = readdir($dp))
	{
		if (is_file($root.$fName) && preg_match($reValidName, $fName) && $pList = new CFPropertyList($root.$fName))
		{
			$data = $pList->toArray();
			$rowQuery = join(' ', array(
				$data['com_panic_transmit_nickname'],
				$data['com_panic_transmit_username'],
				$data['com_panic_transmit_server'],
				$data['com_panic_transmit_remotePath']));
			
			if (!$excludeResults[$data['com_panic_transmit_uniqueIdentifier']] && preg_match($reRowQuery, $rowQuery))
				$results[] = array(
					'uid' => $data['com_panic_transmit_uniqueIdentifier'],
					'arg' => $root.$fName,
					'title' => $data['com_panic_transmit_nickname'],
					'subtitle' => strtolower(
						$data['com_panic_transmit_protocol'].'://'.
						($data['com_panic_transmit_username'] ? $data['com_panic_transmit_username'].'@' : '').
						$data['com_panic_transmit_server'].
						($data['com_panic_transmit_port'] ? ':'.$data['com_panic_transmit_port'] : $defaultPorts[$data['com_panic_transmit_protocol']])).
						$data['com_panic_transmit_remotePath'],
					'icon' => 'icon.png',
					'valid' => true);
		}
	}
} else
	// Unable to open Transmit folder
	$results[] = array(
		'uid' => 'notfound',
		'arg' => 'notfound',
		'title' => 'Favorites Folder Not Found',
		'subtitle' => 'Unable to locate Transmit favorites folder',
		'icon' => 'icon.png',
		'valid' => false);

// No favorites matched
if (!count($results))
	$results[] = array(
		'uid' => 'none',
		'arg' => 'none',
		'title' => 'No Favorites Found',
		'subtitle' => 'No favorites matching your query were found',
		'icon' => 'icon.png',
		'valid' => false);


// Preparing the XML output file
$xmlObject = new SimpleXMLElement("<items></items>");
foreach($results AS $rows)
{
	$nodeObject = $xmlObject->addChild('item');
	$nodeKeys = array_keys($rows);
	foreach ($nodeKeys AS $key)
		$nodeObject->{ $key == 'uid' || $key == 'arg' ? 'addAttribute' : 'addChild' }($key, $rows[$key]);
}

// Print the XML output
echo $xmlObject->asXML();  

?>