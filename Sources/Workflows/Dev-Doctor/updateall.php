<?php

$array = array(
    "css",
    "html",
    "jquery",
    "js",
    "node",
    "php",
    "python",
    "rails",
    "haskell",
    "erlang",
    "caniuse"
);



define("PARSER_URL", "parsers/autosuggest/");

require_once(PARSER_URL."classes/AutoSuggestParser.php");



foreach ($array as $val) {
    $parser = ucFirst($val)."Parser";

    require_once(PARSER_URL."classes/".$val."/".$parser.".php");
    $parser = new $parser;
    $parser->update();
}
