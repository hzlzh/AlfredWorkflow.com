<?php
error_reporting(0); // This is set to off in order to escape an error for timezones not being set.

require('workflows.php');
$w = new Workflows('com.evgeny.golubev.alfred.localservercommands');

$value = shell_exec("ps -ef|grep httpd|grep -v grep");

if (!empty($value)) {
	$w->result('apacherestart', 'apache.restart', 'Restart Apache', 'Restart local Apache server', 'apache.png', 'yes');
	$w->result('apachestop', 'apache.stop', 'Stop Apache', 'Stop local Apache server', 'apache.png', 'yes');
} else if ($match == 0) {
	$w->result('apachestart', 'apache.start', 'Start Apache', 'Start local Apache server', 'apache.png', 'yes');
}

$value = shell_exec("ps -ef|grep mysqld|grep -v grep");

if (!empty($value)) {
	$w->result('mysqlrestart', 'mysql.restart', 'Restart MySQL', 'Restart local MySQL server', 'mysql.png', 'yes');
	$w->result('mysqlstop', 'mysql.stop', 'Stop MySQL', 'Stop local MySQL server', 'mysql.png', 'yes');
} else if ($match == 0) {
	$w->result('mysqlstart', 'mysql.start', 'Start MySQL', 'Start local MySQL server', 'mysql.png', 'yes');
}

echo $w->toxml();