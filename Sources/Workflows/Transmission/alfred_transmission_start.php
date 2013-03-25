#!/usr/bin/env php
<?php

//$id = $argv[0];
$id = 4;

require_once('./class/TransmissionRPC.class.php' );
$rpc = new TransmissionRPC();

$result = $rpc->stop( $id );


?>