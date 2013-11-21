<?php

/*

This script is based on the 'Day' workflow by Matt Gemmel
http://mattgemmell.com/2013/04/01/days-of-the-week-with-alfred-2/

*/

require( 'workflows.php' ); // by David Ferguson
$w = new Workflows();

// Grab the input and trim any surrounding whitespace.
$in = trim( @$argv[1] );

// Parse input. First, default to today.
$timestamp = time();
$today_day = (int)@date("j", $timestamp);
$today_month = (int)@date("n", $timestamp);
$today_year = (int)@date("Y", $timestamp);
$result = 0;

// Determine and resolve ambiguities.
/*
	Expected input:
	* (nothing) = today
	* 7 = date of current month (if sane), or today in given year (if sane)
	* 5/6 = day & month in current year (if sane), order locale-dependent
	* 4/5/6 = day, month, year (if sane), order locale-dependent
*/

$numbers = preg_match_all("/[0-9]+/i", $in, $matches);

// Show today's date.
add_result($w, $today_day, $today_month, four_digit_year($today_year));


// Send results back to Alfred.
echo $w->toxml();


// -- Functions --

function add_result($workflow, $theDay, $theMonth, $theYear) {
	global $today_day, $today_month, $today_year;
	global $result;
	
	$theTimestamp = @mktime(0, 0, 0, $today_month, $today_day, $today_year);
	$WeekNumber = @strftime("%V", $theTimestamp);

	$workflow->result($result.$WeekNumber, $WeekNumber, $WeekNumber, "The week number is $WeekNumber", "./icons/blank.png", 'yes' );
	$result++;
}


function four_digit_year($yr) {
	global $today_year;
	if ($yr < 100) {
		// Make it into a four-digit year.
		$yr += (100 * (floor($today_year / 100)));
	}
	return $yr;
} 

?>