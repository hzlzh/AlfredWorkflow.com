<?php


$data = file_get_contents("http://dochub.io/data/php-ext.json");

$output = "data.php.json";

$data = json_decode($data);

$results = array();


function addResultPHP($url, $title, $description) {


    global $results;
      $results[] = array(
        "url" => $url ,
        "title" => $title,
        "description" =>$description
      );

}

function addResultsPHP($arr) {
    foreach ($arr as $key => $val) {
        $title = $val->title;
        $url = $val->url;
        $description = strip_tags(implode($val->sectionHTMLs, ""));
        //$description = "";
        addResultPHP($url, $title, $description);
        /*
        foreach ($val->searchableItems as $res) {
          addResult($url."#".$res->domId, $res->name, "");
        }
        */

    }
}


addResultsPHP($data);

file_put_contents($output, json_encode($results));
echo "Updated php\n";