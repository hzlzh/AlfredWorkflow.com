<?php
$id = file_get_contents('userid.txt');
$justid = explode("\n",$id,2);
$url_req = "http://api.stackoverflow.com/1.1/users/$justid[0]/favorites";

$query = trim($argv[1]);

$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $url_req);
curl_setopt($curl, CURLOPT_ENCODING, "");
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true); 
$resp = curl_exec($curl);
curl_close($curl);

$data = json_decode($resp, true);
$xml = "<?xml version=\"1.0\"?>\n<items>\n";

foreach ($data["questions"] as $question){
  $url = $question["question_comments_url"];
  $title = $question["title"];
  $tags = $question["tags"];
  $tag_list = implode(",", $tags);
  $term_list = "$title $tag_list";
  $query_matched = stripos($term_list, $query);

  if ( !($query_matched === false) ){
    $xml .= "<item arg=\"http://stackoverflow.com$url\">\n";
    $xml .= "<title>$title</title>\n";
    $xml .= "<subtitle>http://stackoverflow.com$url</subtitle>\n";
    $xml .= "<icon>icon.png</icon>\n";
    $xml .= "</item>\n";
  }
}

$xml .="</items>";
echo $xml;

