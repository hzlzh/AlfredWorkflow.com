<?php
error_reporting(0); // This is set to off in order to escape an error for timezones not being set.

require('workflows.php');
$w = new Workflows('com.evgeny.golubev.alfred.caffeinate');

$min_avaliable = array(10,30,60,120);

$value = shell_exec("ps -ef|grep caff|grep -v grep");
$regex = "/^([\w\W]{0,})([0-9]){1,}([:]{1})([0-9]{2})([APM]{2})([\w\W]{1,})(caffeinate){1}([ \-tdbsi]{0,})([0-9]{0,})/";

$match = preg_match($regex, $value, $matches);

if ($match) {
	$hour = $matches[2];
	$minutes = $matches[4];
	$apm = $matches[5];
	$duration = $matches[9];

	$launch = $hour . ":" . $minutes . $apm;
	$now = shell_exec("date +\"%l:%M%p\"");
	$diff = round(abs(strtotime($now) - strtotime($launch)) / 60);
	$duration = $duration;
	$min = ($duration/60) - $diff;
	
	if ($min > 0) {
		$w->result('caffeinateoff', 'off', 'Deactivate', 'Caffeinate is active for another '.$min.' minutes.', 'icon.png', 'yes');
	} else {
		$w->result('caffeinateoff', 'off', 'Deactivate', 'Caffeinate is currently active for an indefinite period.', 'icon.png', 'yes');
	}
} else if ($match == 0) {
	foreach ($min_avaliable as $min) {
		$w->result('caffeinate'.$min.'min', 'on '.$min, 'Activate for '.$min.' minutes', 'Activate caffeinate for another '.$min.' minutes.', 'icon.png', 'yes');
	}
	
	$w->result('caffeinateindefinitely', 'on indefinitely', 'Activate indefinitely', 'Activate caffeinate for indefinitely period.', 'icon.png', 'yes');
}

echo $w->toxml();