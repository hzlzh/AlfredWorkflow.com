<?php

function units($query = null)//$request, $sourceLanguage = 'auto', $targetLanguage = NULL
{
	

	$url = 'http://time.designandsuch.com/units/one/?q='.urlencode($query).'&v=0.5';
	//http://translate.google.com.br/translate_a/t?client=p&text='.urlencode($phrase).
	//'&hl=en-EN&sl='.$sourceLanguage.'&tl='.$targetLanguage.'&multires=1&ssel=0&tsel=0&sc=1
	//&ie=UTF-8&oe=UTF-8

	$defaults = array(
		CURLOPT_RETURNTRANSFER => true,
		CURLOPT_URL => $url,
		CURLOPT_FRESH_CONNECT => true
	);

	$ch  = curl_init();
	curl_setopt_array($ch, $defaults);
	$out = curl_exec($ch);
	$err = curl_error($ch);
	curl_close($ch);

	$result = '<?xml version="1.0" encoding="utf-8"?><items>';

	$json = json_decode($out);
	//$sourceLanguage = $json->src;
	//
	//if (isset($json->dict)) {
	//	$googleResults = $json->dict[0]->entry;
	//	if (is_array($googleResults)) {
	//		foreach ($googleResults as $translatedData) {
	//			$result .= '<item uid="mtranslate" arg="'.$translatedData->word.'">';
	//			$result .= '<title>'.$translatedData->word.' ('.$knownLanguages[$targetLanguage].')</title>';
	//			$result .= '<subtitle>'.implode(', ', $translatedData->reverse_translation).' ('.$knownLanguages[$sourceLanguage].')</subtitle>';
	//			$result .= '<icon>Icons/'.$targetLanguage.'.png</icon>';
	//			$result .= '</item>';
	//		}
	//	}
	//} elseif (isset($json->sentences)) {
	//	foreach ($json->sentences as $sentence) {
	//		$result .= '<item uid="mtranslate" arg="'.$sentence->trans.'">';
	//		$result .= '<title>'.$sentence->trans.' ('.$knownLanguages[$targetLanguage].')</title>';
	//		$result .= '<subtitle>'.$sentence->orig.' ('.$knownLanguages[$sourceLanguage].')</subtitle>';
	//		$result .= '<icon>Icons/'.$targetLanguage.'.png</icon>';
	//		$result .= '</item>';
	//	}
	//} 
	if (isset($json->items)) {
		foreach ($json->items as $item) {
			$result .= $item;
			//$result .= '<item uid="mtranslate" arg="argument">';
			//$result .= '<title>title</title>';
			//$result .= '<subtitle>subtitle</subtitle>';
			//$result .= '<icon>Icons/icon.png</icon>';
			//$result .= '</item>';
		}
	}else {
		$result .= '<item uid="mtranslate">';
		$result .= '<title>No results found</title>';
		$result .= '</item>';
	}

	$result .= '</items>';
	echo $result;
}

// googleTranslate('über', 'auto', 'en');

?>
