<?php
date_default_timezone_set('GMT');

if (!file_exists('cache')) {
	mkdir('cache');
}

class DocsIndex {
	public $index;
	
	public function loadCache() {
		if (file_exists('cache/index.dat')) {
			$this->index = unserialize(file_get_contents('cache/index.dat'));
		}
	}
	
	public function rebuild() {
		$content = $this->loadUrlCached('http://nodejs.org/api/');
		$content = preg_replace('/^.*<div id="apicontent">\s*<ul>\s*(.+?)\s*<\/ul>\s*<\/div>.*$/is', '$1', $content, 1);
		
		preg_match_all('/<a href="(.*?)">(.*?)<\/a>/i', $content, $matches, PREG_SET_ORDER);
		
		$this->index = array();
		
		foreach ($matches as $match) {
			list(, $href, $title) = $match;
			
			$href = $this->htmlDecode($href);
			$title = $this->htmlDecode($title);
			
			$this->getPageEntries('http://nodejs.org/api/' . $href);
		}
		
		file_put_contents('cache/index.dat', serialize($this->index));
	}
	
	private function getPageEntries($url) {
		$data = $this->loadUrlCached($url);
		
		$url = str_replace('http://nodejs.org/api/', '', $url);
		
		preg_match_all('/<a href="(#.*?)">(.*?)<\/a>/i', $data, $matches, PREG_SET_ORDER);
		
		$links = array();
		$title = str_replace('http://nodejs.org/api/', '', $url);
		
		if (preg_match('/<div id="apicontent">.*?<h1>(.*?)</is', $data, $match)) {
			$title = $this->htmlDecode($match[1]);
		}
		
		foreach ($matches as $match) {
			$match[1] = $this->htmlDecode($match[1]);
			$match[2] = $this->htmlDecode($match[2]);
			
			$links[$url . $match[1]] = $match[2];
		}
		
		$this->index[$title] = $links;
	}
	
	private function loadUrlCached($url) {
		if ($url === 'http://nodejs.org/api/') {
			$cache_file = 'index';
		} else {
			$cache_file = str_replace('http://nodejs.org/api/', '', $url);
			$cache_file = preg_replace('/[^a-z0-9._\-]/i', '-', $cache_file);
		}
		
		$cache_file = 'cache/' . $cache_file;
		
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_HEADER, true);
		
		if (file_exists($cache_file)) {
			if (time() - fileatime($cache_file) < 3600) {
				return file_get_contents($cache_file);
			}
			
			curl_setopt($ch, CURLOPT_TIMECONDITION, CURL_TIMECOND_IFMODSINCE);
			curl_setopt($ch, CURLOPT_TIMEVALUE, filemtime($cache_file));
		}
		
		$chRet = curl_exec($ch);
		$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
		
		if ($code === 304) {
			return file_get_contents($cache_file);
		} else if ($code !== 200) {
			throw new Exception('Failed to fetch "' . $url . '", code: ' . $code);
		}
		
		$headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
		
		curl_close($ch);
		
		$header = substr($chRet, 0, $headerSize);
		$chRet = substr($chRet, $headerSize);
		
		if (preg_match('/^Last-Modified:\s*(.*)$/im', $header, $match)) {
			$mtime = strtotime($match[1]);
			
			if ($mtime) {
				file_put_contents($cache_file, $chRet);
				touch($cache_file, $mtime, time());
			}
		}
		
		return $chRet;
	}
	
	private function htmlDecode($str) {
		$str = html_entity_decode($str);
		$str = preg_replace('/&#(\d+);/me',"chr(\\1)", $str);
		$str = preg_replace('/&#x([a-f0-9]+);/mei','chr(0x\1)', $str);
		
		return $str;
	}
	
	public function filter($str) {
		if (!$this->index) {
			return null;
		}
		
		$results = array();
		
		foreach ($this->index as $page => $links) {
			foreach ($links as $link => $title) {
				if (stripos($link, $str) !== false || stripos($title, $str) !== false) {
					$results[] = (object) array(
						'url' => 'http://nodejs.org/api/' . $link,
						'title' => $title,
						'category' => $page
					);
				}
			}
		}
		
		return $results;
	}
}

$docsIndex = new DocsIndex();

$docsIndex->loadCache();

return $docsIndex;
