<?php
require('workflows.php');
$w = new Workflows();

$token =  $w->get( 'token', 'settings.plist' );
if($token==''){
	$w->result('authenticate', $argv[1], 'Alphred', 'Reauthenitcate Alphred', 'fileicon:/Applications/Alfred.app', 'yes', 'Alfredapp' );
	echo $w->toxml();
}else{
	$w->result('post', $argv[1], 'Alphred', 'Type and press enter to post to ADN', 'fileicon:/Applications/Alfred.app', 'yes', 'Alfredapp' );
	echo $w->toxml();

}
