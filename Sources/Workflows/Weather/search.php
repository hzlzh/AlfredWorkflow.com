<?php

require_once('workflows.php');
$w = new Workflows();

$query = urlencode( $argv[1] );

if ( strlen( $query ) < 3 ):
	exit(1);
endif;

$url = "http://autocomplete.wunderground.com/aq?query=$query&format=json";
$suggestions = $w->request( $url );

$suggestions = json_decode( $suggestions );

$results = array();

foreach( $suggestions->RESULTS as $suggest ):
	$w->result( $suggest->l, $suggest->l, $suggest->name, 'Country: '. $suggest->c .'. Timezone: '. $suggest->tz, 'icon.png' );
endforeach;

echo $w->toxml();