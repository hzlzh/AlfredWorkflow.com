<?

/********************************************
* tba_api_client_PHP5.php
*
* This page contains the client access library for PHP5 to The Blue Alliance API.
* Version: 1, Release date: 02.09.08
* Visit http://thebluealliance.net/ for details.
*
********************************************/

function tba_send_request($method, $arguments=array()) //returns false on error, returns XML on success
{
  $api_key = ""; //replace with your API key
  $api_url = "http://thebluealliance.net/tbatv/api.php"; //this should not change

  $version = 1;

  //basic method/key arguments (required)
  $argument_string = "version=$version&api_key=$api_key&method=$method";
  
  //loop through the array and make the arguments into a string
  foreach ($arguments as $key => $value)
  {
    $argument_string .= "&$key=" . urlencode($value);
  }

  //create a simplexml element based on the arguments
  $file = "{$api_url}?{$argument_string}";
  $xml = simplexml_load_file($file);
  
  //if there is an error, echo it and die, otherwise return the XML elements
  if (count($xml->error) != 0)
  {
    die("Error: ". $xml->error->text);
    return false;
  } else {
    return $xml; //return as xml element (you can run this through make_array() to return a multi-dimensional associative array)
  }
}

//makes an array out of a simplexmlelement object
function make_array($xml)
{
  //convert $xml into an array
  $array = array();
  
  foreach ($xml as $child)
  {
    $row = array();
    foreach ($child as $key => $value)
    {
      $row[$key] = (string) $value;
    }
    $array[] = $row;
  }

  return $array;
}

//methods that call the above and pass arguments based on the function's parameters

function get_teams($teamnumber = NULL, $state = NULL) {
  return tba_send_request("get_teams", array("teamnumber" => $teamnumber, "state" => $state));
}

function get_events($eventid = NULL, $year = NULL, $week = NULL) {
  return tba_send_request("get_events", array("eventid" => $eventid, "year" => $year, "week" => $week));
}

function get_matches($teamnumber = NULL, $eventid = NULL, $matchid = NULL, $complevel = NULL)
{
  return tba_send_request("get_matches", array("eventid" => $eventid, "teamnumber" => $teamnumber, "matchid" => $matchid, "complevel" => $complevel));
}

function get_attendance($eventid = NULL, $teamnumber = NULL) {
  return tba_send_request("get_attendance", array("eventid" => $eventid, "teamnumber" => $teamnumber));
}

function get_official_record($teamnumber, $eventid = NULL, $year = NULL)
{
  return tba_send_request("get_official_record", array("teamnumber" => $teamnumber, "eventid" => $eventid, "year" => $year));
}

function get_elim_sets($eventid, $noun)
{
  return tba_send_request("get_elim_sets", array("eventid" => $eventid, "noun" => $noun));
}

function throw_error($text = NULL) //this exists solely for debugging purposes
{
  return tba_send_request("throw_error", array("text" => $text));
}

?>