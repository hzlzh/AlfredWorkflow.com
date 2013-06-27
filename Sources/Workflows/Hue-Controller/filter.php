<?php

require_once('workflows.php');
$w = new Workflows();


/** Configuration */

$username  = $w->get('api.username',  'settings.plist');
$group     = $w->get('api.group',     'settings.plist');
$bridge_ip = $w->get('api.bridge_ip', 'settings.plist');
$base_path = "/api/$username";

$query = $argv[1];
$control = explode(':', $query);
$results = array();


/** Convenience Functions */

function result($r) {
	global $results;
	if ( ! isset($r['icon']) ):
		$r['icon'] = 'icon.png';
	endif;
	array_push($results, $r);
}

function api_arg($args) {
	global $bridge_ip, $base_path;
	$args['host'] = $bridge_ip;
	// PUT is the default HTTP method since most API calls use this.
	if ( ! isset($args['method']) ):
		$args['method'] = 'PUT';
	endif;
	$args['url'] = $base_path . $args['url'];
	return json_encode($args);
}

function color_picker($id) {
	$rgba = `osascript -e 'tell application "Alfred 2"' -e 'activate' -e 'choose color default color {65535, 65535, 65535}' -e 'end tell'`;
	$hex = '';
	if ( $rgba ):
		$rgba = explode(',', $rgba);
		$rgb = array_slice($rgba, 0, 3);
		// Convert to hex
		foreach ( $rgb as $c ):
			$hex .= substr('0' . dechex(($c / 65535) * 255), -2);
		endforeach;
	endif;
	return `osascript -e 'tell application "Alfred 2" to search "hue $id:color:$hex"'`;
}


/** Cache a reference to lights. */

if ( trim($query) === '' ):
	// clear cache
	$lights = $w->write('', 'lights');
	$lights = $w->request(
		"http://$bridge_ip" . $base_path . '/lights',
		array(CURLOPT_CONNECTTIMEOUT => 3)
	);
	$lights = json_decode($lights, true);
	if ( $lights ):
		$w->write($lights, 'lights');
	endif;
else:
	$lights = $w->read('lights', true);
endif;

if ( ! $lights ):
	result(array(
		'title' => 'Bridge connection failed.',
		'subtitle' => 'Try running "setup-hue".',
		'valid' => 'no'
	));
	echo $w->toxml($results);
	exit;
endif;


/** Generate Results */

if ( $query == 'lights' ):
	foreach ( $lights as $id => $light ):
		result(array(
			'uid' => "light_$id",
			'title' => $light['name'],
			'valid' => 'no',
			'autocomplete' => "$id:"
		));
	endforeach;

elseif ( isset($lights[$query]) ):
	$id = $query;
	$light = $lights[$id];
	result(array(
		'uid' => "light_$id",
		'title' => $light['name'],
		'valid' => 'no',
		'autocomplete' => "$id:"
	));

elseif ( count($control) == 2 ):
	$id = $control[0];
	$partial_query = $control[1];
	result(array(
		'title' => 'Turn off',
		'icon' => 'icons/switch.png',
		'autocomplete' => "$id:off",
		'arg' => api_arg(array(
			'url' => "/lights/$id/state",
			'data' => '{"on": false}'
		))
	));
	result(array(
		'title' => 'Turn on',
		'icon' => 'icons/switch.png',
		'autocomplete' => "$id:on",
		'arg' => api_arg(array(
			'url' => "/lights/$id/state",
			'data' => '{"on": true}'
		))
	));
	result(array(
		'title' => 'Set color...',
		'icon' => 'icons/colors.png',
		'valid' => 'no',
		'autocomplete' => "$id:color:"
	));
	result(array(
		'title' => 'Set effect...',
		'icon' => 'icons/effect.png',
		'valid' => 'no',
		'autocomplete' => "$id:effect:"
	));
	result(array(
		'title' => 'Set brightness...',
		'icon' => 'icons/sun.png',
		'valid' => 'no',
		'autocomplete' => "$id:bri:"
	));
	result(array(
		'title' => 'Set alert...',
		'icon' => 'icons/siren.png',
		'valid' => 'no',
		'autocomplete' => "$id:alert:"
	));
	result(array(
		'title' => 'Rename...',
		'icon' => 'icons/cog.png',
		'valid' => 'no',
		'autocomplete' => "$id:rename:"
	));

elseif ( count($control) == 3 ):
	$id = $control[0];
	$value = $control[2];
	if ( $control[1] == 'bri' ):
		result(array(
			'title' => "Set brightness to $value",
			'subtitle' => 'Set on a scale from 0 to 255, where 0 is off.',
			'icon' => 'icons/sun.png',
			'arg' => api_arg(array(
				'url' => "/lights/$id/state",
				'data' => sprintf('{"bri": %d}', $value)
			))
		));
	elseif ( $control[1] == 'color' ):
		if ( $value == 'colorpicker' ):
			color_picker($id);
		endif;
		result(array(
			'title' => "Set color to $value",
			'subtitle' => 'Accepts 6-digit hex colors or CSS literal color names (e.g. "blue")',
			'icon' => 'icons/colors.png',
			'arg' => api_arg(array(
				'url' => "/lights/$id/state",
				'data' => '',
				'_color' => $value
			))
		));
		result(array(
			'title' => "Use color picker...",
			'valid' => 'no',
			'icon' => 'icons/eyedropper.png',
			'autocomplete' => "$id:color:colorpicker"
		));

	elseif ( $control[1] == 'effect' ):
		result(array(
			'title' => 'None',
			'icon' => 'icons/effect.png',
			'arg' => api_arg(array(
				'url' => "/lights/$id/state",
				'data' => '{"effect": "none"}'
			))
		));
		result(array(
			'title' => 'Color loop',
			'icon' => 'icons/effect.png',
			'arg' => api_arg(array(
				'url' => "/lights/$id/state",
				'data' => '{"effect": "colorloop"}'
			))
		));
	elseif ( $control[1] == 'alert' ):
		result(array(
			'title' => 'None',
			'subtitle' => 'Turn off any ongoing alerts',
			'icon' => 'icons/siren.png',
			'arg' => api_arg(array(
				'url' => "/lights/$id/state",
				'data' => '{"alert": "none"}'
			))
		));
		result(array(
			'title' => 'Blink once',
			'icon' => 'icons/siren.png',
			'arg' => api_arg(array(
				'url' => "/lights/$id/state",
				'data' => '{"alert": "select"}'
			))
		));
		result(array(
			'title' => 'Blink for 30 seconds',
			'icon' => 'icons/siren.png',
			'arg' => api_arg(array(
				'url' => "/lights/$id/state",
				'data' => '{"alert": "lselect"}'
			))
		));

	elseif ( $control[1] == 'rename' ):
		result(array(
			'title' => "Set light name to $value",
			'arg' => api_arg(array(
				'url' => "/lights/$id",
				'data' => sprintf('{"name": "%s"}', $value)
			))
		));
	endif;

else:
	$partial_query = $query;
	result(array(
		'title' => 'Lights',
		'valid' => 'no',
		'autocomplete' => 'lights'
	));
	result(array(
		'title' => 'Turn all lights off',
		'icon' => 'icons/switch.png',
		'autocomplete' => 'off',
		'arg' => api_arg(array(
			'url' => "/groups/$group/action",
			'data' => '{"on": false}'
		))
	));
	result(array(
		'title' =>'Turn all lights on',
		'icon' => 'icons/switch.png',
		'autocomplete' => 'on',
		'arg' => api_arg(array(
			'url' => "/groups/$group/action",
			'data' => '{"on": true}'
		))
	));
	result(array(
		'title' => 'Party',
		'subtitle' => 'Set all lights to color loop.',
		'icon' => 'icons/colors.png',
		'autocomplete' => 'party',
		'arg' => api_arg(array(
			'url' => "/groups/$group/action",
			'data' => '{"effect": "colorloop"}'
		))
	));
	result(array(
		'title' => 'Movie',
		'icon' => 'icons/popcorn.png',
		'subtitle' => 'Set the lights to the minimum brightness.',
		'autocomplete' => 'movie',
		'arg' => api_arg(array(
			'url' => "/groups/$group/action",
			'data' => '{"ct": 500, "sat": 0, "bri": 1}'
		))
	));
endif;

// Filter by partial query.
if ( $partial_query ) {
	function filter_by_query($result) {
		global $partial_query;
		if ( isset($result['autocomplete']) ):
			return stripos($result['autocomplete'], $partial_query) !== false;
		endif;
		return false;
	}
	$results = array_filter($results, 'filter_by_query');
}

echo $w->toxml($results);
exit;
