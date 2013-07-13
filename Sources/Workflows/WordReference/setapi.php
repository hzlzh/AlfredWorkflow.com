<?php
/**
* Name: 		Wordreference.com (© WordReference.com) Workflow for Alfred 2 
* Author: 		Anthony Kevins
* Revised: 		14/06/2013
* Version:		0.3
* Note:   	       Icon Source: A68 - Freelance Graphics Design (http://a68.pl)
*/

$q = $argv[1];
require_once('workflows.php');
$w = new Workflows();
$id = $argv[1];
$w->set('api', $id, 'settings.plist');
echo $id;
?>