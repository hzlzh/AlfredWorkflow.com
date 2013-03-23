<?php

class ExtensionUtils {

	private $plistSettings = null;

	/**
	* Description:
	* Convert an associative array into XML format
	*
	* @param $a - An associative array to convert
	* @return - XML string representation of the array
	*/
	public function arrayToXML( $a ) {
		if ( !$a || !is_array( $a ) ): 						// if the value passed is not an array
			return false;									// return false
		endif;

		$items = new SimpleXMLElement("<items></items>"); 	// Create new XML element

		foreach( $a as $b ):								// Lop through each object in the array
			$c = $items->addChild( 'item' );				// Add a new 'item' element for each object
			$c_keys = array_keys( $b );						// Grab all the keys for that item
			foreach( $c_keys as $key ):						// For each of those keys
				if ( $key == 'uid' ):
					$c->addAttribute( 'uid', $b[$key] );
				elseif ( $key == 'arg' ):
					$c->addAttribute( 'arg', $b[$key] );
				else:
					$c->addChild( $key, $b[$key] );			// Add an element for it and set its value
				endif;
			endforeach;
		endforeach;

		return $items->asXML();								// Return XML string representation of the array
	}

	/**
	* Description:
	* Remove all items from an associative array that do not have a value
	*
	* @param $a - Associative array
	* @return bool
	*/
	private function empty_filter( $a ) {
		if ( $a == '' || $a == null ):						// if $a is empty or null
			return false;									// return false, else, return true
		else:
			return true;
		endif;
	}

	/**
	* Description:
	* Convert a JSON object into XML format
	*
	* @param $a - JSON object
	* @return - XML string representation of the JSON object
	*/
	public function jsonToXML( $a ) {
		$a = json_decode( $a, TRUE );						// Decode the JSON into an associative array
		return arrayToXML( $a );							// Convert that array into an XML string
	}

	/**
	* Description:
	* Initialize all settings. Used to go ahead and initialize all settings that you will use early
	* so if you need to check for existence or check for a value later, if they haven't been initialized
	* you would get error feedback from the defaults command
	*
	* @param array - array of all settings and their values
	* @param file - the plist file to save the values to
	* @return array - array of all settings and their values
	*/
	public function settings( $a, $b )
	{
		$user = exec( 'echo $HOME' );						// Get users home directory
		$this->plistSettings = $user.'/Library/Preferences/'.$b;		// Set path to users Preferences folder (where the plist will be saved)

		if ( !file_exists( $this->plistSettings ) ):
			$this->set( $a );
		endif;

		$settings = array();
		$keys = array_keys( $a );
		foreach($keys as $key):
			$settings[$key] = $this->get( $key );
		endforeach;

		return $settings;
	}

	/**
	* Description:
	* Save an array of values to the plist specified in $b
	*
	* @param $a - associative array of values to save
	* @param $b - the value of the setting
	* @return string - execution output
	*/
	public function set( $a, $b=null )
	{
		if ( is_array($a) ):
			foreach( $a as $k=>$v ):
				exec( 'defaults write "'. $this->plistSettings .'" '. $k .' "'. $v .'"');
			endforeach;
		else:
			exec( 'defaults write "'. $this->plistSettings .'" '. $a .' "'. $b .'"');
		endif;
	}

	/**
	* Description:
	* Read a value from the specified plist
	*
	* @param $a - the value to read
	* @param $b - plist to read the values from
	* @return bool false if not found, string if found
	*/
	public function get( $a ) {

		$out = exec( 'defaults read "'. $this->plistSettings .'" '.$a );	// Execute system call to read plist value

		if ( $out == "" ):
			return false;
		endif;

		return $out;											// Return item value
	}

	/**
	* Description:
	* Read data from a remote file/url, essentially a shortcut for curl
	*
	* @param $url - URL to request
	* @param $options - Array of curl options
	* @return result from curl_exec
	*/
	public function request( $url, $options=null )
	{
		$defaults = array(									// Create a list of default curl options
			CURLOPT_RETURNTRANSFER => true,					// Returns the result as a string
			CURLOPT_URL => $url,							// Sets the url to request
			CURLOPT_FRESH_CONNECT => true
		);

		if ( $options ):
			foreach( $options as $k => $v ):
				$defaults[$k] = $v;
			endforeach;
		endif;

		array_filter( $defaults, 							// Filter out empty options from the array
			array( $this, 'empty_filter' ) );

		$ch  = curl_init();									// Init new curl object
		curl_setopt_array( $ch, $defaults );				// Set curl options
		$out = curl_exec( $ch );							// Request remote data
		$err = curl_error( $ch );
		curl_close( $ch );									// End curl request

		if ( $err ):
			return $err;
		else:
			return $out;
		endif;
	}

	/**
	* Description:
	* Allows searching the local hard drive using mdfind
	*
	* @param $query - search string
	* @param $onlyin - search only within a specified directory (optional)
	* @return array - array of search results
	*/
	public function local_find( $query, $onlyin=null )
	{
		if ( $onlyin == null ):
			exec('mdfind "'.$query.'"', $results);
		else:
			exec('mdfind -onlyin "'.$onlyin.'" "'.$query.'"', $results);
		endif;
		return $results;
	}

	/**
	* Description:
	* Accepts data and a string file name to store data to local file as cache
	*
	* @param array - data to save to file
	* @param file - filename to write the cache data to
	* @return none
	*/
	public function cache( $a, $b )
	{
		file_put_contents( $b, $a );
	}

	/**
	* Description:
	* Returns data from a local cache file
	*
	* @param file - filename to read the cache data from
	* @return none
	*/
	public function cached( $a )
	{
		if ( !file_exists( $a ) ):
			return false;
		endif;

		$return = file_get_contents( $a );
		return $return;
	}

	public function item( $uid, $arg, $title, $sub, $icon, $valid=true )
	{
		$temp = array(
			'uid' => $uid,
			'arg' => $arg,
			'title' => $title,
			'subtitle' => $sub,
			'icon' => $icon,
			'valid' => $valid
		);
		return $temp;
	}

}

class LocalDB extends SQLite3 {

	function __construct( $name = "database.db" )
	{
		$this->open( $name );
	}

	public function single( $table, $where='1', $select='*' )
	{
		$result = $this->querySingle( 'select '. $select .' from '. $table .' where '. $where, true );
		return json_decode( json_encode( $result, JSON_FORCE_OBJECT ) );
	}

	public function get( $table, $where='1', $select='*' )
	{
		$results = $this->query( 'select '. $select .' from '. $table .' where '. $where );
		$return = array();
		while( $result = $results->fetchArray( SQLITE3_ASSOC ) ):
			array_push( $return, $result );
		endwhile;
		return json_decode( json_encode( $return ) );
	}

	public function insert( $table, $values )
	{
		$fieldOrder = "";
		$valueOrder = "";
		$numFields = count( $values );
		$inc = 1;

		foreach( $values as $field => $value ):
			$fieldOrder .= $field;
			if ( $inc != $numFields ):
				$fieldOrder .= ', ';
			endif;
			$valueOrder .= '"'.$value. '"';
			if ( $inc != $numFields ):
				$valueOrder .= ', ';
			endif;
			$inc++;
		endforeach;
		$this->exec( 'insert into ' .$table. ' values ( ' .$valueOrder. ' )' );
	}

	public function delete( $table, $where )
	{
		$this->exec( 'delete from ' .$table. ' where '. $where );
	}

	public function update( $table, $where, $values )
	{
		$setValues = "";
	}

	public function createTable( $table, $fields )
	{
		$fieldDef = "";
		$numFields = count( $fields );
		$inc = 1;

		foreach( $fields as $field => $type ):
			$fieldDef .= $field. " " .strtoupper( $type );
			if ( $inc != $numFields ):
				$fieldDef .= ', ';
			endif;
			$inc++;
		endforeach;

		$this->exec( 'create table if not exists ' .$table. '( ' .$fieldDef. ' )' );
	}

	public function dropTable( $table )
	{
		$this->exec( 'drop table if exists ' .$table );
	}

	function __destruct()
	{
		$this->close();
	}

}