<?php

$auth = $argv[1];

//$os_version = `sw_vers -productVersion`;

if ( $auth == "" ): // left the input blank

	exec('open http://alfredtweet.dferg.us');
	echo "Continuing login at AlfredTweet home page.";

else: // hopefully entered a code

	require_once('alfredtweet.php');

	$tokens = explode("::", $auth);

	if ( count( $tokens ) == 2 ): // hopefully ahve the two tokens

		$alfredtweet = new AlfredTweet();
		$alfredtweet->authenticate( $tokens );
		echo "Settings saved. AlfredTweet is ready to go!";

	else: // not sure what happened or what was given to me..

		echo "Invalid authentication string. Please make sure you copied the entire command.";

	endif;

endif;