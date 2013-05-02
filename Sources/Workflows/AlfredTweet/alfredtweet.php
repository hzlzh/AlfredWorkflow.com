<?php

require_once('twitteroauth.php');

class AlfredTweet
{
	private $authenticated   = false;
	private $consumer_key    = '41EXk56kJ2QnIRRupBZ8w';
	private $consumer_secret = 'QVbe9kY8UppBXxktXYyimfKbTCvg0ZshKUcvtZqPw';
	private $utils;
	private $twitter;
	private $oauth_token;
	private $oauth_token_secret;
	private $username;

	function __construct()
	{
		require_once('workflows.php');
		$this->utils = new Workflows();
		$this->username 			= $this->utils->get( 'username', 'alfredtweet.plist' );
		$this->oauth_token 			= $this->utils->get( 'oauth_token', 'alfredtweet.plist' );
		$this->oauth_token_secret 	= $this->utils->get( 'oauth_token_secret', 'alfredtweet.plist' );
		$this->authenticated 		= $this->utils->get( 'authenticated', 'alfredtweet.plist' );

		$this->twitter = new TwitterOAuth(
			$this->consumer_key,
			$this->consumer_secret,
			$this->oauth_token,
			$this->oauth_token_secret
		);
	}

	/**
	* Description:
	* Accepts the oauth token and oauth token secret as passed
	* parameters and saves those values for later use.
	*
	* @return none
	*/
	public function authenticate( $tokens ) {

		$this->utils->set( 'authenticated', true, 'alfredtweet.plist' );
		$this->utils->set( 'oauth_token', $tokens[0], 'alfredtweet.plist' );
		$this->utils->set( 'oauth_token_secret', $tokens[1], 'alfredtweet.plist' );

		$this->twitter = new TwitterOAuth(
			$this->consumer_key,
			$this->consumer_secret,
			$tokens[0],
			$tokens[1]
		);

		$me = $this->user();
		$this->utils->set( 'username', $me->screen_name, 'alfredtweet.plist' );
	}

	/**
	* Description:
	* Accepts tweet text as a parameter and publishes the text to Twitter as the
	* users status update.
	*
	* @return bool - success/fail
	*/
	public function tweet( $tweet ) {
		$result = $this->twitter->post(
			'statuses/update',
			array(
				'status' => html_entity_decode( $tweet ),
				'wrap_links' => true
			)
		);

		if ( isset( $result->error ) ):
			echo $result->error;
			return false;
		else:
			echo "Tweeted: ". html_entity_decode( $tweet );
			return true;
		endif;
	}

	/**
	* Description:
	* Accepts a username and a message as parameters and sends the message
	* text to the specified user as a direct message on Twitter
	*
	* @param $user - The username to send the message to
	* @param $msg - The message to send to the specified user
	* @return bool - success/fail
	*/
	public function dm( $user, $msg )
	{
		if ( substr( $user, 0, 1) == '@' ):
			$user = substr( $user, 1 );
		endif;
		$result = $this->twitter->post(
			'direct_messages/new',
			array(
				'screen_name' => $user,
				'wrap_links' => true,
				'text' => $msg
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			echo 'Message sent to '. $user;
			return true;
		endif;
	}

	/**
	* Description:
	* Follow the specified user on Twitter
	*
	* @param $user - the user to follow
	* @return bool - success/fail
	*/
	public function follow( $user )
	{
		if ( substr( $user, 0, 1 ) == "@" ):
			$user = substr( $user, 1 );
		endif;
		$result = $this->twitter->post(
			'friendships/create',
			array(
				'screen_name' => $user
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			echo "Now following @".$user;
			return true;
		endif;
	}

	/**
	* Description:
	* Unfollow the specified user on Twitter
	*
	* @param $user - the user to unfollow
	* @return bool - success/fail
	*/
	public function unfollow( $user )
	{
		if ( substr( $user, 0, 1 ) == "@" ):
			$user = substr( $user, 1 );
		endif;
		$result = $this->twitter->post(
			'friendships/destroy',
			array(
				'screen_name' => $user
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			echo "No longer following @".$user;
			return true;
		endif;
	}

	/**
	* Description:
	* Block the specified user on Twitter
	*
	* @param $user - the user to block
	* @return bool - success/fail
	*/
	public function block( $user )
	{
		if ( substr( $user, 0, 1 ) == "@" ):
			$user = substr( $user, 1 );
		endif;
		$result = $this->twitter->post(
			'blocks/create',
			array(
				'screen_name' => $user
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			echo "Now blocking @".$user;
			return true;
		endif;
	}

	/**
	* Description:
	* Unblock the specified user on Twitter
	*
	* @param $user - the user to unblock
	* @return bool - success/fail
	*/
	public function unblock( $user )
	{
		if ( substr( $user, 0, 1 ) == "@" ):
			$user = substr( $user, 1 );
		endif;
		$result = $this->twitter->post(
			'blocks/destroy',
			array(
				'screen_name' => $user
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			echo "Now blocking @".$user;
			return true;
		endif;
	}

	/**
	* Description:
	* Create a new list on Twitter
	*
	* @param $name - the name of the list to create
	* @return bool - success/fail
	*/
	public function createlist( $name )
	{
		$result = $this->twitter->post(
			'lists/create',
			array(
				'name' => $name
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			echo "Created new list: ". $name;
			return true;
		endif;
	}

	/**
	* Description:
	* Delete a list on Twitter
	*
	* @param $name - the name of the list to delete
	* @return bool - success/fail
	*/
	public function destroylist( $name )
	{
		$result = $this->twitter->post(
			'lists/destroy',
			array(
				'list_id' => $name
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			echo "List deleted.";
			return true;
		endif;
	}

	/**
	* Description:
	* Grab a list of all Twitter lists for the current user
	*
	* @param none
	* @return bool - results/fail
	*/
	public function lists()
	{
		$result = $this->twitter->get(
			'lists/list',
			array(
				'screen_name' => $screen_name
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	/**
	* Description:
	* Returns an array of the last 10 user mentions
	*
	* @param none
	* @return array
	*/
	public function mentions()
	{
		$result = $this->twitter->get(
			'statuses/mentions_timeline',
			array(
				'count' => 10
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	/**
	* Description:
	* Search Twitter for the specified term
	*
	* @param $query - the term to search for
	* @return bool - results/fail
	*/
	public function search( $query )
	{
		$result = $this->twitter->get(
			'search/tweets',
			array(
				'q' => $query,
				'result_type' => 'recent'
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	/**
	* Description:
	* Grab info on the specified user
	*
	* @param $user - username to look up, "me" for current user
	* @return bool - result/false
	*/
	public function user( $user = "me" )
	{
		if ( $user == "me" ):
			$result = $this->twitter->get(
				'account/verify_credentials',
				array(
					'skip_status' => true
				)
			);
		else:
			if ( substr( $user, 0, 1 ) == "@" ):
				$user = substr( $user, 1 );
			endif;
			$result = $this->twitter->get(
				'users/show',
				array(
					'screen_name' => $user
				)
			);
		endif;
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	/**
	* Description:
	* Return the last 8 tweets from the current users timeline
	*
	* @param - none
	* @return bool - results/fail
	*/
	public function timeline()
	{
		$result = $this->twitter->get(
			'statuses/home_timeline',
			array(
				'count' => 10
			)
		);
		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	public function users( $query )
	{
		$result = $this->twitter->get(
			'users/search',
			array(
				'q' => $query,
				'count' => 10,
				'include_entities' => false
			)
		);

		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	public function whoami()
	{
		return $this->username;
	}

	public function followers()
	{
		$result = $this->twitter->get(
			'followers/ids',
			array(
				'screen_name' => 'jdfwarrior',
				'count' => 5000,
				'cursor' => -1
			)
		);

		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	public function friends()
	{
		$result = $this->twitter->get(
			'friends/ids',
			array(
				'screen_name' => 'jdfwarrior',
				'count' => 5000,
				'cursor' => -1
			)
		);

		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

	public function lookup( $id )
	{
		$result = $this->twitter->get(
			'users/lookup',
			array(
				'user_id' => $id,
				'include_entities' => false
			)
		);

		if ( $result->error ):
			echo $result->error;
			return false;
		else:
			return $result;
		endif;
	}

}