<?php
include_once("workflows.php");

$wf = new Workflows();

$name = "/tut.*/i";
exec("/Users/richardguay/bin/s3cmd ls", $listdir);

$count = 1;
foreach($listdir as $dirItem) {
	if((strcmp($dirItem,"") != 0)&&(preg_match($name,$dirItem) === 1)){
		$wf->result('s3cmd:list' . $count, $dirItem, $dirItem, '', 'icon.png', 'yes', 'auto');
		$count = $count + 1;
	}
}

//
// Add the default list of cleaners.
//
$wf->result('s3c999', '', 'Quit', '', 'icon.png', 'no', '');

echo $wf->toxml();
?>