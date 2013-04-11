<?php

function googleTranslate($request, $sourceLanguage, $targetLanguage)
{
	$url = 'http://translate.google.com.br/translate_a/t?client=p&text='.urlencode($request).'&hl=en-EN&sl='.$sourceLanguage.'&tl='.$targetLanguage.'&multires=1&ssel=0&tsel=0&sc=1';
	
	$defaults = array(									CURLOPT_RETURNTRANSFER => true,					CURLOPT_URL => $url,
		CURLOPT_FRESH_CONNECT => true
	);

	$ch  = curl_init();
	curl_setopt_array($ch, $defaults);
	$out = curl_exec($ch);
	$err = curl_error($ch);
	curl_close($ch);

	$result = '<?xml version="1.0"?><items>';

	$json = json_decode(utf8_encode($out));
	if (isset($json->dict)) {
		$googleResults = $json->dict[0]->entry;
		if (is_array($googleResults)) {
			foreach ($googleResults as $translatedData) {
				$result .= '<item uid="mtranslate" arg="'.$translatedData->word.'">';
				$result .= '<title>'.$translatedData->word.'</title>';
				$result .= '<subtitle>'.implode(', ', $translatedData->reverse_translation).'</subtitle>';
				$result .= '<icon>'.$targetLanguage.'.png</icon>';
				$result .= '</item>';
			}
		}
	} elseif (isset($json->sentences)) {
		foreach ($json->sentences as $sentence) {
			$result .= '<item uid="mtranslate" arg="'.$sentence->trans.'">';
			$result .= '<title>'.$sentence->trans.'</title>';
			$result .= '<subtitle>'.$sentence->orig.'</subtitle>';
			$result .= '<icon>'.$targetLanguage.'.png</icon>';
			$result .= '</item>';
		}
	} else {
		$result .= '<item uid="mtranslate">';
		$result .= '<title>No results found</title>';
		$result .= '</item>';
	}

	$result .= '</items>';
	echo $result;
}

// googleTranslate('Wohnmobil', 'de', 'en');

?>