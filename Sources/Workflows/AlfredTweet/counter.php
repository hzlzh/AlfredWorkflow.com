<?php

require_once('workflows.php');
require_once('sqlitedb.php');

$input = $argv[1];

$w = new Workflows();
$db = new SQLiteDB( 'autocomplete.db' );

$table = array( 'handle' => 'text PRIMARY KEY' );
$db->create_table( $table, 'users' );

$remaining = ( 140 - count( str_split( trim ( $input ) ) ) );

$w->result( 'tweet', $input, 'Tweet: '.$input, 'Remaining: '.$remaining. '. Press Cmd+Enter to send.', 'icon.png' );

$words = explode( ' ', $input );
if ( preg_match( '^@[a-zA-Z0-9-_]{2,}^' , end( $words ) ) ):
	$search = substr( end( $words ), 1 );
	$matches = $db->select('*')->from('users')->like( 'handle', $search )->get();
	array_pop( $words );
	$words = implode( ' ', $words );
	foreach( $matches as $match ):
		$w->result('autoc', $words.' @'.$match->handle.' ', $match->handle, '', 'icon.png', 'no', $words.' @'.$match->handle.' ' );
	endforeach;
endif;

echo $w->toxml();