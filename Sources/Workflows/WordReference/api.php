<?php
/**
* Name: 		Wordreference.com (© WordReference.com) Workflow for Alfred 2 
* Author: 		Anthony Kevins
* Revised: 		06/06/2013
* Version:		0.2
* Note:   	       Icon Source: A68 - Freelance Graphics Design (http://a68.pl)
*/

require_once('workflows.php');
$w = new Workflows();
$q = $argv[1];
$id = urlencode($q);
$w->result(	
	'setting API',
	$q,
	"Set API to '$q'",
	'Enter a valid API, or press command-enter to go get one.',
	'icon.png',
	'yes');
echo $w->toxml();
?>
