<?php
require_once('workflows.php');

$w = new Workflows();
	
if (file_exists($w->data() . "/library.json"))
{
	echo "Library has been updated";
}
else
{
	echo "Library has been created";
}
putenv('LANG=fr_FR.UTF-8');
$fp = fopen ($w->data() . "/library.json", 'w+');
fwrite($fp, exec('pbpaste'));
fclose($fp);
?>