<?php
require_once('workflows.php');
$w = new Workflows();

$w->set( 'is_spotifious_active', $argv[1], 'settings.plist' );
echo "Spotifious activation has been set to  $argv[1]";
?>