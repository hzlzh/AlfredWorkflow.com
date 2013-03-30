<?php

$keywords = $argv[1];
$doc = new DOMDocument;

// this file has been serialized from Core Data (http://en.wikipedia.org/wiki/Core_Data).
$doc->load(getenv('HOME') . '/Library/Application Support/Snippets/Snippets.xml');

$xpath = new DOMXPath($doc);

// create list of tags
$tagList = array();
foreach ($xpath->query('//object[@type="TAG"]') as $tag) {
	$tagList[$tag->getAttribute('id')] = $xpath->query('./attribute[@name="name"]', $tag)->item(0)->nodeValue;
}

echo '<?xml version="1.0"?>';
echo '<items>';

// iterate over all snippets
foreach ($xpath->query('//object[@type="SNIPPET"]') as $snippet) {
	// ignore deleted ones
	if ($xpath->query('./attribute[@name="dateremoved"]', $snippet)->item(0)) {
		continue;
	}

	$match = true;
	$tags = array();
	$name = $xpath->query('./attribute[@name="name"]', $snippet)->item(0)->nodeValue;
	$tagIds = $xpath->query('./relationship[@name="tags"]', $snippet)->item(0)->getAttribute('idrefs');
	$codeId = $xpath->query('./relationship[@name="code"]', $snippet)->item(0)->getAttribute('idrefs');
	$code = $xpath->query('//object[@type="CODE" and @id="' . $codeId . '"]/attribute[@name="content"]')->item(0)->nodeValue;

	if ($tagIds) {
		foreach(explode(' ', $tagIds) as $tagId) {
			$tags[] = $tagList[$tagId];
		}
	}

	// do a case-insensitive match on all keywords and see if we have a snippet with a matching tag, name, or code
	foreach(explode(' ', $keywords) as $keyword) {
		if (!in_array(strtolower($keyword), array_map('strtolower', $tags)) && !stristr($name, $keyword) && !stristr($code, $keyword)) {
			$match = false;
		}
	}

	// we got a match!
	if ($match) {
		$title = $name;

		if (!empty($tags)) {
			$title .= ' (' . implode(', ', $tags) . ')';
		}

		// unescape slashes (they are escaped in the XML file)
		$code = str_replace('\\\\', '\\', $code);

		// encode the code in base64 to preserve newlines
		echo "  <item uid=\"" . $snippet->getAttribute('id') . "\" arg=\"" . base64_encode($code) . "\">\n";
		echo "    <title>" . $title . "</title>\n";
		echo "    <subtitle>" . htmlspecialchars($code, ENT_QUOTES, 'utf-8') . "</subtitle>\n";
		echo "    <icon>icon.png</icon>\n";
		echo "    <valid>yes</valid>\n";
		echo "  </item>\n";
	}
}

echo '</items>';