<?php

class LeoParser{
	
	function get($input) {
		libxml_use_internal_errors( true );
		libxml_clear_errors();
		
		$doc = new DOMDocument();
		$doc->loadHtml($input);
		$xpath = new DOMXPath($doc);
		$mainElements = $xpath->query("//div[@class='section results']");
		
		$resultArray = array();
		foreach ($mainElements as $mainElement) {
			$this->parseEntries($doc->saveHtml($mainElement), $resultArray);
		}
		return $resultArray;
	}
	
	function parseEntries($input, array & $resultArray) {
		$wordDoc = new DOMDocument();
		$wordDoc->loadHtml($input);
		$wordXPath = new DOMXPath($wordDoc);
		$elements = $wordXPath->query("//table/*/tr/td[@class='text']");
		$output = "";

		$i = 1;
		$resultEntry = new ParserResult();		
		foreach ($elements as $element) {
			$subElements = $element->getElementsByTagName("small");
			do {
				$moreTags = $this->removeSmallTags($element);
			} while($moreTags->length != 0);
			$this->removeSmallTags($element);

			$isSearchWord = $this->isSearchWord($element);
			$languageCode = $this->getLanguageCode($element);
			
			$value = utf8_decode(trim($element->nodeValue));
			
			if ($i % 2 != 0) {
				if ($isSearchWord) {
					$resultEntry->originalWord = $value;
				} else {
					$resultEntry->languageCode = $languageCode;
					$resultEntry->translatedWord = $value;
				}
			} else {
				if ($resultEntry->languageCode == "") {
					$resultEntry->languageCode = $languageCode;
					$resultEntry->translatedWord = $value;
				} else {
					$resultEntry->originalWord = $value;
				}
		    	array_push($resultArray, $resultEntry);
				$resultEntry = new ParserResult();
 			}
			$i++;
		}
	}
	
	function removeSmallTags(DOMElement $element) {
		$subElements = $element->getElementsByTagName("small");
		try {
			foreach ($subElements as $subElement) {
				$element->removeChild($subElement);
			}
		} catch(Exception $e) {
		}
		return $element->getElementsByTagName("small")->length;
	}
	
	function isSearchWord(DOMElement $element) {
		$subElements = $element->getElementsByTagName("b");
		if ($subElements->length > 0) {
			return true;
		}
		return false;
	}
	
	function getLanguageCode(DOMElement $element) {
		return $element->getAttribute("lang");
	}
	
}

class ParserResult {
	public $translatedWord = "";
	public $originalWord = "";
	public $languageCode = "";
}

?>