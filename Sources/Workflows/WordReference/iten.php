<?php
/**
* Name: 		Wordreference.com (© WordReference.com) Workflow for Alfred 2 
* Author: 		Anthony Kevins
* Revised: 		6/06/2013
* Version:		0.2
* Note:   	       Icon Source: A68 - Freelance Graphics Design (http://a68.pl)
*/

require_once('workflows.php');
$w = new Workflows('wordreference');
$id = $w->get('api','settings.plist');
if(!$id){
	$w->result(
		'wordreference-noapi',
		'open http://www.wordreference.com/docs/APIregistration.aspx',
		'You must provide a WordReference API to use the workflow',
		"Get an API using 'getapi', then set it with 'setapi'",
		'icon.png',
		'yes'
	);
	echo $w->toxml();
	return;
}
$query = urlencode( $argv[1] );
$url = "http://api.wordreference.com/0.8/$id/json/iten/$query";
$translations = $w->request( $url );
$translations = json_decode( $translations );
$i = "";
foreach( $translations->term0->PrincipalTranslations as $translation ):
	foreach( $translation as $trkey => $tr ):
		$icon='icon.png';
		if ($trkey == "OriginalTerm"):
			$icon = 'italy.png';
		endif;
		if ($trkey !== "Note"):
			$w->result( 
				$i, 
				$query, 
				$tr->term,
				$tr->POS . " " . $tr->sense,  
			$icon, 
			'yes' );
		endif;
	endforeach;
endforeach;
echo $w->toxml();