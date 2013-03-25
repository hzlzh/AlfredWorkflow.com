<?php



$parser = ucFirst($type)."Parser";

define("PARSER_URL", "parsers/autosuggest/");

require_once(PARSER_URL."classes/AutoSuggestParser.php");

require_once(PARSER_URL."classes/".$type."/".$parser.".php");

require_once('workflows.php');

$parser = new $parser;

$icon = PARSER_URL."classes/".$type."/".$parser->icon;


$data = file_get_contents(PARSER_URL."data/".$parser->data_filename);


$wf = new Workflows();


$data = json_decode($data);

if (!isset($icon)) {
    $icon = "icon.png";
}

$query = strtolower($query);

$arr = get_defined_functions();

$extras = array();

$extras2 = array();

foreach ($data as $key => $result){

    $value = $result->title;
    $description = utf8_decode(strip_tags($result->description));

    if (strpos(strtolower($value), $query) === 0) {
        $wf->result( $key.$result->title, $result->url, $type.": ".$result->title, $result->description,$icon  );
    }
    else if (strpos(strtolower($value), $query) > 0) {
        $extras[$key] = $result;
    }

    else if (strpos($description, $query) !== false) {
        $extras2[$key] = $result;
    }
}

foreach ($extras as $key => $value) {
        $wf->result( $key.$result->title, $result->url, $type.": ".$result->title, $result->description, $icon  );

}

foreach ($extras2 as $key => $value) {
        $wf->result( $key.$result->title, $result->url, $type.": ".$result->title, $result->description, $icon  );

}

echo $wf->toxml();

