<?php
require_once('workflows.php');
$wf = new Workflows();

$query = trim($argv[1]);
$site = '美团';
$icon = 'icon.png';

$requestOption = array(
    CURLOPT_POST => true,
    CURLOPT_HTTPHEADER => array('Content-length:0', 'X-Requested-With:XMLHttpRequest'),
);
$json = $wf->request("http://www.meituan.com/search/smartbox/".urlencode($query), $requestOption);
$items = json_decode($json);
$items = $items->data;

foreach($items as $item) {

        $url = sprintf('http://www.meituan.com/s/?w=%s', urlencode($item));
        $subtitle = sprintf('查看全部与%s有关的团购', $item);
        $wf->result("$url", "在美团上搜索: $item", "$subtitle", $icon);
}

$url = sprintf('http://www.meituan.com/s/?w=', $query);
$results = $wf->results();
if (count($results) == 0):
    $wf->result($url, 'No Suggestions', 'No search suggestions found. Search 美团 for '.$query, 'icon.png');
endif;

echo $wf->toxml();
