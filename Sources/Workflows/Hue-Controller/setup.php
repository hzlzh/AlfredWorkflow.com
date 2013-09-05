<?php

require_once('workflows.php');
$w = new Workflows();

// Make sure settings file exists.
exec('touch settings.plist');


/** Send request to Portal API to discover bridges on the local network. */

$bridges = $w->request('http://www.meethue.com/api/nupnp');
$bridges = json_decode($bridges, true);

if ( empty($bridges) ):
	die('No bridges found on your network.');
endif;

$bridge_ip = $bridges[0]['internalipaddress'];
$w->set('api.bridge_ip', $bridge_ip, 'settings.plist');


/** Set API group */

if ( ! empty($argv[1]) && is_numeric($argv[1]) ):
	$group = (int) $argv[1];
else:
	$group = 0;
endif;

$w->set('api.group', $group, 'settings.plist');


/** Create API user for this workflow. */

$resp = $w->request("http://$bridge_ip/api", array(
	CURLOPT_POST => true,
	CURLOPT_POSTFIELDS => '{"devicetype": "Alfred"}'
));

$resp = json_decode($resp, true);

if ( isset($resp[0]['error']) ):
	die('Setup Error: ' . $resp[0]['error']['description']);
endif;

$username = $resp[0]['success']['username'];

$w->set('api.username', $username, 'settings.plist');

echo 'Success! You can now control your lights by using the "hue" keyword.';
exit;
