<?php
require_once('workflows.php');

$w = new Workflows();

$created = false;
if (file_exists($w->data() . "/library.json"))
{
	$created = true;
}

putenv('LANG=fr_FR.UTF-8');

ini_set('memory_limit', '512M' );

//try to decode it 
$json = json_decode(exec('pbpaste'));
if (json_last_error() === JSON_ERROR_NONE) 
{ 
	$fp = fopen ($w->data() . "/library.json", 'w+');
	fwrite($fp, exec('pbpaste'));
	fclose($fp);
	
	if($created == true)
	{
		echo "Library has been updated";
	}
	else
	{
		echo "Library has been created";
	}
} 
else 
{ 
    //it's not JSON. Log error
    echo "ERROR: JSON data is not valid!";
    unlink($w->data() . "/library.json");
}	
?>