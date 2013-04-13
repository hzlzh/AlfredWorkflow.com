<?php
require_once('workflows.php');
$w = new Workflows();

$w->set( 'max_results', $argv[1], 'settings.plist' );
echo "Max results has been set to $argv[1]";
?>