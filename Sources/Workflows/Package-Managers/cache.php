<?php

class cache {
	var $cache_age = 14;
	var $dbs = array(
		"alcatraz" => "https://raw.github.com/mneorr/alcatraz-packages/master/packages.json",
		"apple" => "http://cocoadocs.org/apple_documents.jsonp", // CocoaDocs
		"cocoa" => "http://cocoadocs.org/documents.jsonp",
		"grunt" => "http://gruntjs.com/plugin-list",
	);
	var $query_file = "queries";
	
	function __construct() {
		$this->w = new Workflows();
		
		$q = $this->w->read($this->query_file.'.json');
		$this->queries = $q ? (array)$q : array();
	}
	
	function __destruct() {
		$this->w->write($this->queries, $this->query_file.'.json');
	}
	
	function get_db($id) {
		if (!array_key_exists($id, $this->dbs)) { return array(); }
		$name = $id;
		
		$pkgs = $this->w->read($name.'.json');
		$timestamp = $this->w->filetime($name.'.json');
		if (!$pkgs || $timestamp < (time() - $this->cache_age * 86400) ) {
			$data = $this->w->request( $this->dbs[$id] );
			if (substr($this->dbs[$id], -5) == 'jsonp') { $data = preg_replace('/.+?([\[{].+[\]}]).+/','$1',$data); } // clean jsonp wrapper
			$this->w->write($data, $name.'.json');
			$pkgs = json_decode( $data );
		} else if (!$pkgs) {
			$pkgs = array();
		}
		return $pkgs;
	}
	
	function get_query_json($id, $query, $url) {
		if (!$query) { return array(); }
		$name = $id.'.'.$query;
		
		$pkgs = $this->w->read($name.'.json');
		$timestamp = $this->w->filetime($name.'.json');
		if (!$pkgs || $timestamp < (time() - $this->cache_age * 86400)) {
			$data = $this->w->request($url);
			if (substr($url, -5) == 'jsonp') { $data = preg_replace('/.+?([\[{].+[\]}]).+/','$1',$data); } // clean jsonp wrapper
			$this->w->write($data, $name.'.json');
			$this->queries[$name] = time();
			$pkgs = json_decode( $data );
		} else if (!$pkgs) {
			$pkgs = array();
		}
		return $pkgs;
	}
	
	function get_query_regex($id, $query, $url, $regex, $regex_pos = 1) {
		if (!$query) { return array(); }
		$name = $id.'.'.$query;
		
		$pkgs = $this->w->read($name.'.json');
		$timestamp = $this->w->filetime($name.'.json');
		if (!$pkgs || $timestamp < (time() - $this->cache_age * 86400)) {
			$data = $this->w->request($url);
			preg_match_all($regex, $data, $matches);
			$data = $matches[$regex_pos];
			$this->w->write($data, $name.'.json');
			$pkgs = is_string($data) ? json_decode( $data ) : $data;
			$this->queries[$name] = time();
		} else if (!$pkgs) {
			$pkgs = array();
		}
		return $pkgs;
	}
	
	function update_db($id) {
		$data = $this->w->request( $this->dbs[$id] );
	
		// clean jsonp wrapper
		$data = preg_replace('/.+?({.+}).+/','$1',$data);
		
		$this->w->write($data, $id.'.json');
		return $data;
	}
	
	function clear() {
		// remove db json files
		foreach($this->dbs as $key => $url) {
			$this->w->delete($key.'.json');
			
		}
		
		// remove query json files
		foreach($this->queries as $key => $timestamp) {
			$this->w->delete($key.'.json');
		}
		$this->queries = array();
	}
}

?>