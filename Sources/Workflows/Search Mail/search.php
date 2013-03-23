<?php

include('extension_utils.php');

$utils = new ExtensionUtils();

$query = $argv[1];

if ( strlen( $query ) < 3 ):
	exit(1);
endif;

$home = exec('printf $HOME');
$maildir = "$home/Library/Mail/V2";

$results = $utils->local_find(
	"(kMDItemContentType == 'com.apple.mail.emlx') && (kMDItemSubject == '*".$query."*'c || kMDItemAuthors == '*".$query."*'c || kMDItemAuthorEmailAddresses == '*".$query."*'c)"
);

$results = array_slice($results, 0, 15);

$output = array();

foreach( $results as $k => $v ):

	exec("mdls -name kMDItemSubject -raw '$v'", $title);
	exec("mdls -name kMDItemAuthors -raw '$v'", $subtitle);

	$subtitle = trim( str_replace( "\"", "" , $subtitle[1] ) );

	$temp = array(
		'title' => utf8_encode( htmlentities( $title[0] ) ),
		'subtitle' => "From: ". utf8_encode( htmlentities( $subtitle ) ),
		'icon' => 'icon.png',
		'uid' => '',
		'arg' => $v
	);

	array_push($output, $temp);

	unset($title, $subtitle);

endforeach;

echo $utils->arrayToXML( $output );