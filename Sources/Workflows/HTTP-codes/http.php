<?php
require_once('workflows.php');
$wf = new Workflows();

$query = $argv[1];

$codes = array(
  '100' => array('Continue', 'sec10.1.1'),
  '101' => array('Switching Protocols', 'sec10.1.2'),
  '200' => array('OK', 'sec10.2.1'),
  '201' => array('Created', 'sec10.2.2'),
  '202' => array('Accepted', 'sec10.2.3'),
  '204' => array('No Content', 'sec10.2.5'),
  '205' => array('Reset Content', 'sec10.2.6'),
  '206' => array('Partial Content', 'sec10.2.7'),
  '300' => array('Multiple Choices', 'sec10.3.1'),
  '301' => array('Moved Permanently', 'sec10.3.2'),
  '302' => array('Found', 'sec10.3.3'),
  '303' => array('See Other', 'sec10.3.4'),
  '304' => array('Not Modified', 'sec10.3.5'),
  '305' => array('Use Proxy', 'sec10.3.6'),
  '307' => array('Temporary Redirect', 'sec10.3.8'),
  '400' => array('Bad Request', 'sec10.4.1'),
  '401' => array('Unauthorized', 'sec10.4.2'),
  '402' => array('Payment Required', 'sec10.4.3'),
  '403' => array('Forbidden', 'sec10.4.4'),
  '404' => array('Not Found', 'sec10.4.5'),
  '405' => array('Method Not Allowed', 'sec10.4.6'),
  '406' => array('Not Acceptable', 'sec10.4.7'),
  '407' => array('Proxy Authentication Required', 'sec10.4.8'),
  '408' => array('Request Timeout', 'sec10.4.9'),
  '409' => array('Conflict', 'sec10.4.10'),
  '410' => array('Gone', 'sec10.4.11'),
  '411' => array('Length Required', 'sec10.4.12'),
  '412' => array('Precondition Failed', 'sec10.4.13'),
  '413' => array('Request Entity Too Large', 'sec10.4.14'),
  '415' => array('Unsupported Media Type', 'sec10.4.16'),
  '416' => array('Requested Range Not Satisfiable', 'sec10.4.17'),
  '417' => array('Expectation Failed', 'sec10.4.18'),
  '500' => array('Internal Server Error', 'sec10.5.1'),
  '501' => array('Not Implemented', 'sec10.5.2'),
  '502' => array('Bad Gateway', 'sec10.5.3'),
  '503' => array('Service Unavailable', 'sec10.5.4'),
  '504' => array('Gateway Timeout', 'sec10.5.5'),
  '505' => array('HTTP Version Not Supported', 'sec10.5.6')
);

$base_url = "http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html";

foreach ($codes as $code => $data) {
    if (0 === strpos($code, $query)) {
        $wf->result($code, "$base_url#$data[1]", "$code $data[0]", "See detail of $code", 'icon.png');
    }
}

$results = $wf->results();

if (count($results) == 0) {
    $wf->result(0, $query, 'Not Found', 'Truly 404...', 'icon.png' );
}

echo $wf->toxml();

?>
